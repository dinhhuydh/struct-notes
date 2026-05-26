class ArticlesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_article, only: %i[show edit update destroy]
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def index
    @articles = current_user.articles.recent
  end

  def show
  end

  def new_upload
    @templates = Template.system_templates
    @default_template = Template.default_template
  end

  def generate
    @templates = Template.system_templates

    raw_notes = extract_notes
    if raw_notes.nil?
      redirect_to new_upload_articles_path, alert: @upload_error and return
    end

    template = Template.find_by(id: params[:template_id]) || Template.default_template

    unless current_user.can_generate?
      redirect_to new_upload_articles_path, alert: "You've reached your monthly generation limit (#{current_user.generation_limit}). Please try again next month." and return
    end

    begin
      result = ArticleGeneratorService.new.call(raw_notes, template)
      @article = current_user.articles.create!(
        raw_notes: raw_notes,
        template: template,
        title: result["title"],
        hook: result["hook"],
        body_sections: result["body_sections"],
        best_for: result["best_for"],
        not_for: result["not_for"],
        ethics_notes: result["ethics_notes"],
        key_facts: result["key_facts"],
        status: "draft"
      )
      current_user.increment_generation_count!
      redirect_to edit_article_path(@article), notice: "Article generated! Review and edit before publishing."
    rescue ArticleGeneratorService::GenerationError => e
      redirect_to new_upload_articles_path, alert: e.message
    end
  end

  def edit
  end

  def update
    if @article.update(article_params)
      redirect_to @article, notice: "Article saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article.destroy
    redirect_to articles_path, notice: "Article deleted."
  end

  private

  def set_article
    @article = current_user.articles.find(params[:id])
  end

  def article_params
    permitted = params.require(:article).permit(:title, :hook, :best_for, :not_for, :ethics_notes, :status)

    if params[:article][:body_sections_attributes].present?
      sections = params[:article][:body_sections_attributes].values.map do |s|
        { "heading" => s[:heading], "content" => s[:content], "source_excerpt" => @article.body_sections&.dig(s.keys.first.to_i, "source_excerpt") }
      end
      # Preserve source_excerpt from existing data
      sections = params[:article][:body_sections_attributes].to_unsafe_h.sort_by { |k, _| k.to_i }.map do |_, s|
        existing = @article.body_sections&.find { |bs| bs["heading"] == s["heading"] }
        { "heading" => s["heading"], "content" => s["content"], "source_excerpt" => existing&.dig("source_excerpt") || "" }
      end
      permitted[:body_sections] = sections
    end

    if params[:article][:key_facts_attributes].present?
      facts = params[:article][:key_facts_attributes].to_unsafe_h.sort_by { |k, _| k.to_i }.map do |_, f|
        existing = @article.key_facts&.find { |kf| kf["label"] == f["label"] }
        { "label" => f["label"], "value" => f["value"], "source_excerpt" => existing&.dig("source_excerpt") || "" }
      end
      permitted[:key_facts] = facts
    end

    permitted
  end

  def extract_notes
    if params[:file].present?
      validate_and_extract_file(params[:file])
    elsif params[:raw_notes].present? && params[:raw_notes].strip.length >= 50
      params[:raw_notes].strip
    elsif params[:raw_notes].present?
      @upload_error = "Your notes are too short (minimum 50 characters). Please add more detail."
      nil
    else
      @upload_error = "Please provide notes — either paste text or upload a .docx file."
      nil
    end
  end

  def validate_and_extract_file(file)
    unless file.content_type == "application/vnd.openxmlformats-officedocument.wordprocessingml.document" ||
           file.original_filename&.end_with?(".docx")
      @upload_error = "Invalid file format. Please upload a .docx file."
      return nil
    end

    if file.size > 50.megabytes
      @upload_error = "File exceeds the 50 MB limit. Please upload a smaller file."
      return nil
    end

    begin
      text = DocxParser.extract_text(file.tempfile.path)
    rescue => e
      @upload_error = "Could not read this file. It may be corrupted — please try re-saving as .docx."
      return nil
    end

    if text.strip.length < 50
      @upload_error = "The document doesn't contain enough text to generate an article. Please add more notes."
      return nil
    end

    text.strip
  end

  def not_found
    head :not_found
  end
end
