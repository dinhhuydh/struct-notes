class ArticleGeneratorService
  class GenerationError < StandardError; end

  API_TIMEOUT = 60

  def call(raw_notes, template)
    api_key = ENV["ANTHROPIC_API_KEY"]
    model = ENV.fetch("ANTHROPIC_MODEL", "claude-sonnet-4-20250514")

    unless api_key.present?
      raise GenerationError, "AI service is not configured. Please contact the administrator."
    end

    prompt = template.prompt_template % { raw_notes: raw_notes }

    begin
      client = Anthropic::Client.new(
        api_key: api_key,
        timeout: API_TIMEOUT
      )

      response = client.messages.create(
        model: model,
        max_tokens: 4096,
        messages: [
          { role: "user", content: prompt }
        ],
        system: "You are a travel magazine editor. Always respond with valid JSON only. No markdown, no code fences, no explanation — just the JSON object."
      )

      parse_response(response)
    rescue Anthropic::Errors::APITimeoutError
      raise GenerationError, "Article generation timed out. Please try again."
    rescue Anthropic::Errors::AuthenticationError
      raise GenerationError, "AI service authentication failed. Please contact the administrator."
    rescue Anthropic::Errors::RateLimitError
      raise GenerationError, "AI service is temporarily busy. Please try again in a moment."
    rescue Anthropic::Errors::InternalServerError
      raise GenerationError, "AI service is temporarily unavailable. Please try again later."
    rescue Anthropic::Errors::APIConnectionError => e
      Rails.logger.error("Anthropic connection error: #{e.class} - #{e.message}")
      Rails.logger.error("Cause: #{e.cause.class} - #{e.cause&.message}") if e.cause
      Rails.logger.error(e.backtrace.first(10).join("\n"))
      raise GenerationError, "Could not reach the AI service. (#{e.cause&.class}: #{e.cause&.message})"
    rescue Anthropic::Errors::APIStatusError => e
      Rails.logger.error("Anthropic status error: #{e.class} - #{e.message}")
      msg = extract_api_error_message(e)
      raise GenerationError, "AI service error: #{msg}"
    rescue StandardError => e
      Rails.logger.error("Unexpected error during article generation: #{e.class} - #{e.message}")
      Rails.logger.error(e.backtrace.first(5).join("\n"))
      raise GenerationError, "An unexpected error occurred: #{e.message}"
    end
  end

  private

  def parse_response(response)
    text = extract_text(response)
    raise GenerationError, "AI returned an empty response. Please try again." if text.blank?

    text = text.gsub(/\A```json\s*/, "").gsub(/\s*```\z/, "").strip

    parsed = JSON.parse(text)
    validate_structure(parsed)
    parsed
  rescue JSON::ParserError
    raise GenerationError, "AI returned an unexpected response format. Please try again."
  end

  def extract_text(response)
    if response.respond_to?(:content)
      block = response.content&.first
      block.respond_to?(:text) ? block.text : block.dig("text")
    else
      response.dig("content", 0, "text")
    end
  end

  def validate_structure(data)
    required = %w[title hook body_sections]
    missing = required - data.keys
    if missing.any?
      raise GenerationError, "AI response is missing required fields: #{missing.join(', ')}. Please try again."
    end
  end

  def extract_api_error_message(error)
    body = error.message.to_s
    if body.include?("credit balance is too low")
      "Your Anthropic API credit balance is too low. Please add credits at console.anthropic.com."
    elsif body.include?("invalid_request_error")
      match = body.match(/:message=>"([^"]+)"/)
      match ? match[1] : "Invalid request to AI service."
    else
      "Unexpected error. Please try again."
    end
  end
end
