class Article < ApplicationRecord
  belongs_to :user
  belongs_to :template, optional: true

  validates :raw_notes, presence: true
  validates :status, inclusion: { in: %w[draft published] }

  scope :drafts, -> { where(status: "draft") }
  scope :published, -> { where(status: "published") }
  scope :recent, -> { order(created_at: :desc) }

  def draft?
    status == "draft"
  end

  def published?
    status == "published"
  end
end
