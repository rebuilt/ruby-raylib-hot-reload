class CloudBlock < Block
  include Raylib

  def initialize(pos, dim, color, frameTime = 0, maxFrames = 1)
    super(pos, dim, color, frameTime, maxFrames)
  end

  def update
  end

  def draw
    DrawTexture(ResourceManager.textures["blockCloud"], @pos.x, @pos.y, WHITE)

    if GameWorld.debug && @color.a != 0
      DrawRectangle(@pos.x, @pos.y, @dim.x, @dim.y, Fade(@color, 0.5))
    end
  end
end
