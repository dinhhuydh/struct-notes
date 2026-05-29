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

  # Versioning tests
  test "original_article returns self when no parent" do
    article = articles(:komodo_draft)
    assert_equal article, article.original_article
  end

  test "original_article returns parent for a version" do
    v2 = articles(:komodo_v2)
    assert_equal articles(:komodo_draft), v2.original_article
  end

  test "all_versions returns all versions including self" do
    article = articles(:komodo_draft)
    versions = article.all_versions
    assert_includes versions, article
    assert_includes versions, articles(:komodo_v2)
    assert_equal 2, versions.count
  end

  test "all_versions from a child also returns all versions" do
    v2 = articles(:komodo_v2)
    versions = v2.all_versions
    assert_equal 2, versions.count
    assert_includes versions, articles(:komodo_draft)
  end

  test "has_versions? returns true when versions exist" do
    assert articles(:komodo_draft).has_versions?
  end

  test "has_versions? returns false for standalone article" do
    assert_not articles(:published_article).has_versions?
  end

  test "next_version_number returns incremented number" do
    article = articles(:komodo_draft)
    assert_equal 3, article.next_version_number
  end

  test "next_version_number returns 2 for standalone article" do
    article = articles(:published_article)
    assert_equal 2, article.next_version_number
  end

  test "originals scope excludes versions" do
    originals = users(:alice).articles.originals
    assert_includes originals, articles(:komodo_draft)
    assert_includes originals, articles(:published_article)
    assert_not_includes originals, articles(:komodo_v2)
  end

  # Rating tests
  test "rating defaults to nil" do
    article = Article.new
    assert_nil article.rating
  end

  test "validates rating inclusion" do
    article = articles(:komodo_draft)
    article.rating = "invalid"
    assert_not article.valid?
  end

  test "allows nil rating" do
    article = articles(:komodo_draft)
    article.rating = nil
    assert article.valid?
  end

  test "rated? returns false when not rated" do
    assert_not articles(:komodo_draft).rated?
  end

  test "rated_up? returns true when rated up" do
    article = articles(:komodo_draft)
    article.update!(rating: "up")
    assert article.rated_up?
    assert article.rated?
  end

  test "rated_down? returns true when rated down" do
    article = articles(:komodo_draft)
    article.update!(rating: "down")
    assert article.rated_down?
  end
end
