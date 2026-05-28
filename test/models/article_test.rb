require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  test "validates raw_notes presence" do
    article = Article.new(user: users(:alice), status: "draft")
    assert_not article.valid?
    assert_includes article.errors[:raw_notes], "can't be blank"
  end

  test "validates status inclusion" do
    article = articles(:komodo_draft)
    article.status = "invalid"
    assert_not article.valid?
    assert_includes article.errors[:status], "is not included in the list"
  end

  test "validates tone inclusion" do
    article = articles(:komodo_draft)
    article.tone = "invalid_tone"
    assert_not article.valid?
    assert_includes article.errors[:tone], "is not included in the list"
  end

  test "default tone is magazine_editorial" do
    article = Article.new
    assert_equal "magazine_editorial", article.tone
  end

  test "TONES contains expected keys" do
    expected = %w[magazine_editorial casual_fun luxury backpacker poetic]
    assert_equal expected.sort, Article::TONES.keys.sort
  end

  test "tone_label returns human-readable label" do
    article = articles(:komodo_draft)
    assert_equal "Magazine Editorial", article.tone_label
  end

  test "tone_instruction returns prompt instruction" do
    article = articles(:komodo_draft)
    assert_match(/polished/, article.tone_instruction)
  end

  test "draft? returns true for draft articles" do
    assert articles(:komodo_draft).draft?
  end

  test "published? returns true for published articles" do
    assert articles(:published_article).published?
  end

  test "recent scope orders by created_at desc" do
    articles = users(:alice).articles.recent
    assert articles.first.created_at >= articles.last.created_at
  end

  test "belongs to user" do
    article = articles(:komodo_draft)
    assert_equal users(:alice), article.user
  end

  test "belongs to template optionally" do
    article = articles(:komodo_draft)
    assert_equal templates(:travel_experience), article.template
  end
end
