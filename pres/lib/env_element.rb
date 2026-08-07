class EnvElement
  attr_accessor :rect, :blocking, :color

  def initialize(rect, blocking, color)
    @rect = rect
    @blocking = blocking
    @color = color
  end
end
