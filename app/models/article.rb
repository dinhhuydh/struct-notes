class Article < ApplicationRecord
  TONES = {
    "magazine_editorial" => {
      label: "Magazine Editorial",
      instruction: "Write in a polished, professional magazine editorial style."
    },
    "casual_fun" => {
      label: "Casual & Fun",
      instruction: "Write in a casual, upbeat, conversational tone — like telling a friend about the trip."
    },
    "luxury" => {
      label: "Luxury & Sophisticated",
      instruction: "Write in an elegant, refined tone suited for a luxury travel publication."
    },
    "backpacker" => {
      label: "Backpacker / Budget",
      instruction: "Write in a practical, down-to-earth tone focused on budget tips and real experiences."
    },
    "poetic" => {
      label: "Poetic & Atmospheric",
      instruction: "Write in a lyrical, evocative tone that paints vivid sensory pictures."
    }
  }.freeze

  belongs_to :user
  belongs_to :template, optional: true
  belongs_to :parent, class_name: "Article", optional: true
  has_many :versions, class_name: "Article", foreign_key: :parent_id, dependent: :nullify

  RATINGS = %w[up down].freeze

  validates :raw_notes, presence: true
  validates :status, inclusion: { in: %w[draft published] }
  validates :tone, inclusion: { in: TONES.keys }
  validates :rating, inclusion: { in: RATINGS }, allow_nil: true

  scope :drafts, -> { where(status: "draft") }
  scope :published, -> { where(status: "published") }
  scope :recent, -> { order(created_at: :desc) }
  scope :originals, -> { where(parent_id: nil) }

  def draft?
    status == "draft"
  end

  def published?
    status == "published"
  end

  def tone_label
    TONES.dig(tone, :label) || tone&.humanize
  end

  def tone_instruction
    TONES.dig(tone, :instruction) || ""
  end

  # Returns the root article in the version chain
  def original_article
    parent || self
  end

  # Returns all versions including self, ordered by version number
  def all_versions
    root = original_article
    Article.where(id: root.id).or(Article.where(parent_id: root.id)).order(:version_number)
  end

  def has_versions?
    all_versions.count > 1
  end

  def next_version_number
    all_versions.maximum(:version_number).to_i + 1
  end

  def rated?
    rating.present?
  end

  def rated_up?
    rating == "up"
  end

  def rated_down?
    rating == "down"
  end
end
