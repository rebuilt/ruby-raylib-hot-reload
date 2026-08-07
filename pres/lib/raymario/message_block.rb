class MessageBlock < Block
  include Raylib

  attr_accessor :message, :moveAnimationTime, :moveAnimationAcum, :moveAnimationStarted, :moveY

  def initialize(pos, dim, color, *args)
    if args[0].is_a?(String)
      message = args[0]
      frameTime = 0
      maxFrames = 1
    else
      frameTime = args[0]
      maxFrames = args[1]
      message = args[2]
    end

    super(pos, dim, color, frameTime, maxFrames)

    @message = message
    @moveAnimationTime = 0.1
    @moveAnimationAcum = 0.0
    @moveAnimationStarted = false
    @moveY = 0.0
  end

  def update
  end

  def draw
    if @moveAnimationStarted
      delta = GetFrameTime
      @moveAnimationAcum += delta

      if @moveAnimationAcum >= @moveAnimationTime
        @moveY = 0
        @moveAnimationAcum = 0
        @moveAnimationStarted = false
      else
        @moveY += 100 * delta
      end
    end

    DrawTexture(ResourceManager.textures["blockMessage"], @pos.x, @pos.y - @moveY, WHITE)

    if GameWorld.debug && @color.a != 0
      DrawRectangle(@pos.x, @pos.y, @dim.x, @dim.y, Fade(@color, 0.5))
    end
  end

  def doHit(mario, map)
    unless @hit
      PlaySound(ResourceManager.sounds["messageBlock"])
      @hit = true
      @moveAnimationStarted = true
      map.setDrawMessage(true)
      map.setMessage(@message)
      map.pauseGameToShowMessage
    end
  end
end
