class CutUpGenerator
  def initialize(source_text)
    @source_text = source_text
  end

  def generate
    lines = @source_text.content.split("\n").reject(&:blank?)
    shuffled = lines.shuffle
    shuffled.join("\n")
  end
end