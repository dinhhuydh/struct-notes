require "test_helper"

class ArticleGeneratorServiceTest < ActiveSupport::TestCase
  setup do
    @service = ArticleGeneratorService.new
    @template = templates(:travel_experience)
    @raw_notes = "Went on a 3 day Komodo boat trip. Sailed through stunning islands. Cost about $300 per person. Saw giant dragons up close."
  end

  test "raises GenerationError when API key is missing" do
    original = ENV["ANTHROPIC_API_KEY"]
    ENV["ANTHROPIC_API_KEY"] = nil
    begin
      error = assert_raises(ArticleGeneratorService::GenerationError) do
        @service.call(@raw_notes, @template)
      end
      assert_match(/not configured/, error.message)
    ensure
      ENV["ANTHROPIC_API_KEY"] = original
    end
  end

  test "raises GenerationError when API key is blank" do
    original = ENV["ANTHROPIC_API_KEY"]
    ENV["ANTHROPIC_API_KEY"] = ""
    begin
      error = assert_raises(ArticleGeneratorService::GenerationError) do
        @service.call(@raw_notes, @template)
      end
      assert_match(/not configured/, error.message)
    ensure
      ENV["ANTHROPIC_API_KEY"] = original
    end
  end

  test "parse_response extracts valid JSON" do
    response = { "content" => [{ "text" => '{"title":"Test","hook":"Hook","body_sections":[{"heading":"H","content":"C","source_excerpt":"S"}],"best_for":"All","not_for":"None","ethics_notes":null,"key_facts":[]}' }] }
    result = @service.send(:parse_response, response)
    assert_equal "Test", result["title"]
    assert_equal "Hook", result["hook"]
    assert_kind_of Array, result["body_sections"]
  end

  test "parse_response strips markdown code fences" do
    json = '{"title":"Test","hook":"Hook","body_sections":[{"heading":"H","content":"C","source_excerpt":"S"}]}'
    response = { "content" => [{ "text" => "```json\n#{json}\n```" }] }
    result = @service.send(:parse_response, response)
    assert_equal "Test", result["title"]
  end

  test "parse_response raises on invalid JSON" do
    response = { "content" => [{ "text" => "not json at all" }] }
    assert_raises(ArticleGeneratorService::GenerationError) do
      @service.send(:parse_response, response)
    end
  end

  test "parse_response raises on missing required fields" do
    response = { "content" => [{ "text" => '{"title":"Test"}' }] }
    assert_raises(ArticleGeneratorService::GenerationError) do
      @service.send(:parse_response, response)
    end
  end

  test "parse_response raises on empty response" do
    response = { "content" => [{ "text" => "" }] }
    assert_raises(ArticleGeneratorService::GenerationError) do
      @service.send(:parse_response, response)
    end
  end
end
