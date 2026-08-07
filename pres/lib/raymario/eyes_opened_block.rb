class EyesOpenedBlock < Block
  include Raylib

  attr_accessor :animationTime, :animationAcum

  def initialize(pos, dim, color, frameTime = 0.1, maxFrames = 4)
    super(pos, dim, color, frameTime, maxFrames)
    @animationTime = 3
    @animationAcum = 0.0
  end

  def update
    delta = GetFrameTime

    @frameAcum += delta

    if @frameAcum >= @frameTime
      @frameAcum = 0
      @currentFrame += 1
      @currentFrame %= @maxFrames
    end

    if @hit
      @animationAcum += delta
      if @animationAcum >= @animationTime
        @hit = false
        @animationAcum = 0
        @currentFrame = 0
        @state = SPRITE_STATE_IDLE
      end
    end
  end

  def draw
    if @hit
      DrawTexture(ResourceManager.textures["blockEyesOpened#{@currentFrame}"], @pos.x, @pos.y, WHITE)
    else
      DrawTexture(ResourceManager.textures["blockEyesOpened0"], @pos.x, @pos.y, WHITE)
    end

    if GameWorld.debug && @color.a != 0
      DrawRectangle(@pos.x, @pos.y, @dim.x, @dim.y, Fade(@color, 0.5))
    end
  end

  def doHit(mario, map)
    unless @hit
      PlaySound(ResourceManager.sounds["shellRicochet"])
      @hit = true
      @state = SPRITE_STATE_NO_COLLIDABLE
    end
  end
end
