class Player
  attr_accessor :position, :speed, :canJump

  def initialize
    @position = Vector2.create(400, 280)
    @speed = 0.0
    @canJump = false
  end
end
