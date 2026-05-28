require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "can_generate? returns true when under limit" do
    user = users(:alice)
    assert user.can_generate?
  end

  test "can_generate? returns false when at limit" do
    user = users(:bob)
    user.update!(generations_this_month: 5)
    assert_not user.can_generate?
  end

  test "increment_generation_count! increases count by 1" do
    user = users(:alice)
    assert_difference -> { user.reload.generations_this_month }, 1 do
      user.increment_generation_count!
    end
  end

  test "validates name presence" do
    user = User.new(email: "test@test.com", password: "password123", name: nil)
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "has many articles" do
    user = users(:alice)
    assert_respond_to user, :articles
  end

  # Plan tests
  test "default plan is free" do
    user = User.new
    assert_equal "free", user.plan
  end

  test "free? returns true for free users" do
    assert users(:alice).free?
  end

  test "pro? returns true for pro users" do
    assert users(:pro_user).pro?
  end

  test "free user has generation_limit of 5" do
    assert_equal 5, users(:alice).generation_limit
  end

  test "pro user has generation_limit of 200" do
    assert_equal 200, users(:pro_user).generation_limit
  end

  test "upgrade_to_pro! changes plan and limit" do
    user = users(:alice)
    user.upgrade_to_pro!
    assert user.pro?
    assert_equal 200, user.generation_limit
  end

  test "generations_remaining returns correct count" do
    user = users(:bob)
    assert_equal 1, user.generations_remaining
  end

  test "plan_label returns human-readable label" do
    assert_equal "Free", users(:alice).plan_label
    assert_equal "Pro", users(:pro_user).plan_label
  end

  # Monthly reset tests
  test "resets count when reset_at is older than 1 month" do
    user = users(:bob)
    user.update_columns(generations_this_month: 5, generation_count_reset_at: 2.months.ago)
    assert user.can_generate?
    assert_equal 0, user.generations_this_month
  end

  test "does not reset count when reset_at is within 1 month" do
    user = users(:bob)
    assert_equal 4, user.generations_this_month
  end

  test "new user gets plan defaults via before_create" do
    user = User.create!(name: "New", email: "new@test.com", password: "password123")
    assert_equal "free", user.plan
    assert_equal 5, user.generation_limit
    assert_not_nil user.generation_count_reset_at
  end
end
