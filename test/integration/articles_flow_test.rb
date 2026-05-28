require "test_helper"

class ArticlesFlowTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:alice)
  end

  test "redirects to sign in when not authenticated" do
    get articles_path
    assert_redirected_to new_user_session_path
  end

  test "shows article index when signed in" do
    sign_in @user
    get articles_path
    assert_response :success
    assert_select "h1", "Your Articles"
  end

  test "shows new upload form with tone selector" do
    sign_in @user
    get new_upload_articles_path
    assert_response :success
    assert_select "h1", "Create New Article"
    assert_select "select[name='template_id']"
    assert_select "select[name='tone']"
    assert_select "select[name='tone'] option", count: Article::TONES.size
  end

  test "shows article" do
    sign_in @user
    article = articles(:komodo_draft)
    get article_path(article)
    assert_response :success
    assert_select "h1", article.title
  end

  test "shows edit form" do
    sign_in @user
    article = articles(:komodo_draft)
    get edit_article_path(article)
    assert_response :success
    assert_select "input[value='#{article.title}']"
  end

  test "updates article" do
    sign_in @user
    article = articles(:komodo_draft)
    patch article_path(article), params: { article: { title: "Updated Title", status: "published" } }
    assert_redirected_to article_path(article)
    article.reload
    assert_equal "Updated Title", article.title
    assert_equal "published", article.status
  end

  test "deletes article" do
    sign_in @user
    article = articles(:komodo_draft)
    assert_difference("Article.count", -1) do
      delete article_path(article)
    end
    assert_redirected_to articles_path
  end

  test "cannot access other user's articles" do
    sign_in users(:bob)
    article = articles(:komodo_draft)
    get article_path(article)
    assert_response :not_found
  end

  test "generate rejects empty notes" do
    sign_in @user
    post generate_articles_path, params: { raw_notes: "", template_id: templates(:travel_experience).id }
    assert_redirected_to new_upload_articles_path
    assert_match(/provide notes/, flash[:alert])
  end

  test "generate rejects short notes" do
    sign_in @user
    post generate_articles_path, params: { raw_notes: "too short", template_id: templates(:travel_experience).id }
    assert_redirected_to new_upload_articles_path
    assert_match(/too short/, flash[:alert])
  end

  test "generate rejects user at limit" do
    user = users(:bob)
    user.update!(generations_this_month: 20)
    sign_in user
    post generate_articles_path, params: {
      raw_notes: "A" * 100,
      template_id: templates(:travel_experience).id
    }
    assert_redirected_to new_upload_articles_path
    assert_match(/generation limit/, flash[:alert])
  end

  test "landing page shows for unauthenticated users" do
    get root_path
    assert_response :success
    assert_select "h1", /Turn travel notes into/
  end

  test "authenticated root redirects to articles" do
    sign_in @user
    get root_path
    assert_response :success
  end

  # Versioning tests
  test "shows regenerate form" do
    sign_in @user
    article = articles(:komodo_draft)
    get regenerate_article_path(article)
    assert_response :success
    assert_select "h1", "Regenerate Article"
    assert_select "select[name='template_id']"
    assert_select "select[name='tone']"
  end

  test "shows versions page" do
    sign_in @user
    article = articles(:komodo_draft)
    get versions_article_path(article)
    assert_response :success
    assert_select "h1", "Version History"
  end

  test "index only shows original articles" do
    sign_in @user
    get articles_path
    assert_response :success
    assert_select "h2", articles(:komodo_draft).title
    assert_select "h2", text: articles(:komodo_v2).title, count: 0
  end

  test "show page displays version badge when versions exist" do
    sign_in @user
    get article_path(articles(:komodo_draft))
    assert_select "a", "v1"
  end

  test "show page has no version badge for standalone article" do
    sign_in @user
    get article_path(articles(:published_article))
    assert_select "a", text: /^v\d+$/, count: 0
  end

  test "show page has regenerate button" do
    sign_in @user
    get article_path(articles(:komodo_draft))
    assert_select "a", "Regenerate"
  end

  test "regenerate rejects user at limit" do
    user = users(:bob)
    user.update!(generations_this_month: 20)
    sign_in user
    # Create an article for bob to regenerate
    article = user.articles.create!(raw_notes: "A" * 100, title: "Test", status: "draft", template: templates(:travel_experience))
    post regenerate_article_path(article), params: { template_id: templates(:travel_experience).id, tone: "casual_fun" }
    assert_redirected_to article_path(article)
    assert_match(/generation limit/, flash[:alert])
  end
end
