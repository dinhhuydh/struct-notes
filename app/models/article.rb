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

  validates :raw_notes, presence: true
  validates :status, inclusion: { in: %w[draft published] }
  validates :tone, inclusion: { in: TONES.keys }

  scope :drafts, -> { where(status: "draft") }
  scope :published, -> { where(status: "published") }
  scope :recent, -> { order(created_at: :desc) }

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
end
