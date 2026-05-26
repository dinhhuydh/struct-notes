class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :articles, dependent: :destroy

  validates :name, presence: true
  validates :generation_limit, numericality: { greater_than: 0 }

  def can_generate?
    generations_this_month < generation_limit
  end

  def increment_generation_count!
    increment!(:generations_this_month)
  end

  def reset_monthly_count!
    update!(generations_this_month: 0)
  end
end
