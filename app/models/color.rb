Color = Struct.new(:name, :value)

class Color
  class << self
    def for_value(value)
      COLORS.find { |it| it.value == value }
    end
  end

  def to_s
    value
  end

  COLORS = {
    "Blue" => "var(--color-card-default)",
    "Gray" => "oklch(var(--lch-ink-dark))",
    "Tan" => "oklch(var(--lch-uncolor-medium))",
    "Yellow" => "oklch(var(--lch-yellow-medium))",
    "Lime" => "oklch(var(--lch-lime-medium))",
    "Aqua" => "oklch(var(--lch-aqua-medium))",
    "Violet" => "oklch(var(--lch-violet-medium))",
    "Purple" => "oklch(var(--lch-purple-medium))",
    "Pink" => "oklch(var(--lch-pink-medium))"
  }.collect { |name, value| new(name, value) }.freeze
end
