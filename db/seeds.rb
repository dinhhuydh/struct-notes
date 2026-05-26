travel_experience_prompt = <<~PROMPT
  You are a travel magazine editor. Convert the following rough travel notes into a structured magazine article.

  IMPORTANT RULES:
  - Only use information present in the notes. Do NOT invent facts, prices, or details.
  - For every claim or fact, include the exact excerpt from the original notes that supports it in the "source_excerpt" field.
  - If the notes don't contain enough information for a section, write "Not mentioned in notes" rather than making something up.

  Return a JSON object with this exact structure:
  {
    "title": "A compelling article title",
    "hook": "A 1-2 sentence intro that hooks the reader",
    "body_sections": [
      {
        "heading": "Section heading",
        "content": "Section content as prose",
        "source_excerpt": "The exact text from the notes this section is based on"
      }
    ],
    "best_for": "Who this experience is best suited for",
    "not_for": "Who should avoid this experience",
    "ethics_notes": "Any ethical considerations or safety notes (or null if not relevant)",
    "key_facts": [
      {
        "label": "Fact label (e.g. Price, Duration, Season)",
        "value": "Fact value",
        "source_excerpt": "The exact text from the notes supporting this fact"
      }
    ]
  }

  THE NOTES:
  %{raw_notes}
PROMPT

hotel_review_prompt = <<~PROMPT
  You are a travel magazine editor specializing in accommodation reviews. Convert the following rough notes into a structured hotel/stay review.

  IMPORTANT RULES:
  - Only use information present in the notes. Do NOT invent facts, prices, or details.
  - For every claim or fact, include the exact excerpt from the original notes that supports it in the "source_excerpt" field.
  - If the notes don't contain enough information for a section, write "Not mentioned in notes" rather than making something up.

  Return a JSON object with this exact structure:
  {
    "title": "A compelling review title",
    "hook": "A 1-2 sentence intro that sets the scene",
    "body_sections": [
      {
        "heading": "Section heading (e.g. The Room, Location, Amenities, Service, Dining)",
        "content": "Section content as prose",
        "source_excerpt": "The exact text from the notes this section is based on"
      }
    ],
    "best_for": "Who this stay is best suited for (e.g. couples, families, solo travelers)",
    "not_for": "Who might not enjoy this stay",
    "ethics_notes": "Any sustainability or ethical notes (or null if not relevant)",
    "key_facts": [
      {
        "label": "Fact label (e.g. Price per night, Location, Check-in, Star rating)",
        "value": "Fact value",
        "source_excerpt": "The exact text from the notes supporting this fact"
      }
    ]
  }

  THE NOTES:
  %{raw_notes}
PROMPT

food_dining_prompt = <<~PROMPT
  You are a travel magazine editor specializing in food and dining experiences. Convert the following rough notes into a structured food/dining article.

  IMPORTANT RULES:
  - Only use information present in the notes. Do NOT invent facts, prices, or details.
  - For every claim or fact, include the exact excerpt from the original notes that supports it in the "source_excerpt" field.
  - If the notes don't contain enough information for a section, write "Not mentioned in notes" rather than making something up.

  Return a JSON object with this exact structure:
  {
    "title": "A compelling article title",
    "hook": "A 1-2 sentence intro that hooks the reader",
    "body_sections": [
      {
        "heading": "Section heading (e.g. The Atmosphere, The Food, Must-Try Dishes, The Experience)",
        "content": "Section content as prose",
        "source_excerpt": "The exact text from the notes this section is based on"
      }
    ],
    "best_for": "Who this dining experience suits (e.g. foodies, budget travelers, date night)",
    "not_for": "Who might not enjoy this",
    "ethics_notes": "Any ethical considerations like sustainability, local sourcing (or null if not relevant)",
    "key_facts": [
      {
        "label": "Fact label (e.g. Price range, Cuisine type, Location, Opening hours)",
        "value": "Fact value",
        "source_excerpt": "The exact text from the notes supporting this fact"
      }
    ]
  }

  THE NOTES:
  %{raw_notes}
PROMPT

templates = [
  {
    name: "Travel Experience",
    slug: "travel-experience",
    description: "General travel experience article — adventures, tours, hikes, boat trips, sanctuaries, etc.",
    prompt_template: travel_experience_prompt,
    is_default: true
  },
  {
    name: "Hotel & Stay Review",
    slug: "hotel-review",
    description: "Accommodation review — hotels, hostels, homestays, resorts, glamping, etc.",
    prompt_template: hotel_review_prompt,
    is_default: false
  },
  {
    name: "Food & Dining",
    slug: "food-dining",
    description: "Food and dining experience — restaurants, street food, cooking classes, food tours, etc.",
    prompt_template: food_dining_prompt,
    is_default: false
  }
]

templates.each do |attrs|
  Template.find_or_create_by!(slug: attrs[:slug]) do |t|
    t.name = attrs[:name]
    t.description = attrs[:description]
    t.prompt_template = attrs[:prompt_template]
    t.is_default = attrs[:is_default]
  end
end

puts "Seeded #{Template.count} templates"
