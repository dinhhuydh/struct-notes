class User < ApplicationRecord
  PLANS = {
    "free" => { label: "Free", generation_limit: 5, price: 0 },
    "pro" => { label: "Pro", generation_limit: 200, price: 19 }
  }.freeze

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :articles, dependent: :destroy

  validates :name, presence: true
  validates :generation_limit, numericality: { greater_than: 0 }
  validates :plan, inclusion: { in: PLANS.keys }

  before_create :set_plan_defaults

  def can_generate?
    reset_monthly_count_if_needed!
    generations_this_month < generation_limit
  end

  def increment_generation_count!
    reset_monthly_count_if_needed!
    increment!(:generations_this_month)
  end

  def generations_remaining
    reset_monthly_count_if_needed!
    [generation_limit - generations_this_month, 0].max
  end

  def free?
    plan == "free"
  end

  def pro?
    plan == "pro"
  end

  def plan_label
    PLANS.dig(plan, :label) || plan&.capitalize
  end

  def upgrade_to_pro!
    update!(
      plan: "pro",
      generation_limit: PLANS["pro"][:generation_limit]
    )
  end

  private

  def set_plan_defaults
    self.plan ||= "free"
    self.generation_limit = PLANS.dig(plan, :generation_limit) || 5
    self.generation_count_reset_at ||= Time.current
  end

  def reset_monthly_count_if_needed!
    return if generation_count_reset_at.present? && generation_count_reset_at > 1.month.ago

    update_columns(
      generations_this_month: 0,
      generation_count_reset_at: Time.current
    )
  end
end
