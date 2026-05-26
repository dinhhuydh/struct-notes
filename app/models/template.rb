class Template < ApplicationRecord
  belongs_to :user, optional: true
  has_many :articles, dependent: :nullify

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :prompt_template, presence: true

  scope :system_templates, -> { where(user_id: nil) }

  def self.default_template
    find_by(is_default: true) || system_templates.first
  end

  def system?
    user_id.nil?
  end
end
