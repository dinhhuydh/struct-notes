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

  test "shows new upload form" do
    sign_in @user
    get new_upload_articles_path
    assert_response :success
    assert_select "h1", "Create New Article"
    assert_select "select[name='template_id']"
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
end
