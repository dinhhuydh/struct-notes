require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "can_generate? returns true when under limit" do
    user = users(:alice)
    assert user.can_generate?
  end

  test "can_generate? returns false when at limit" do
    user = users(:bob)
    user.update!(generations_this_month: 20)
    assert_not user.can_generate?
  end

  test "increment_generation_count! increases count by 1" do
    user = users(:alice)
    assert_difference -> { user.reload.generations_this_month }, 1 do
      user.increment_generation_count!
    end
  end

  test "reset_monthly_count! resets to zero" do
    user = users(:bob)
    user.reset_monthly_count!
    assert_equal 0, user.generations_this_month
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
end
