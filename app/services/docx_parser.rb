class DocxParser
  class ParseError < StandardError; end

  def self.extract_text(file_path)
    doc = Docx::Document.open(file_path)
    paragraphs = doc.paragraphs.map(&:text).reject(&:blank?)
    paragraphs.join("\n\n")
  rescue Zip::Error, Errno::ENOENT => e
    raise ParseError, "Could not read the .docx file: #{e.message}"
  end
end
