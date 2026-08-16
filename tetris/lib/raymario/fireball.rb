class Fireball < Sprite
  attr_accessor :timeSpan, :timeSpanAcum

  def initialize(pos, dim, vel, color, facingDirection, timeSpan)
    super(pos, dim, vel, color, 0.05, 4, facingDirection)
    @timeSpan = timeSpan
    @timeSpanAcum = 0.0
    setState(SPRITE_STATE_ACTIVE)
  end

  def update
    delta = GetFrameTime

    @frameAcum += delta
    if @frameAcum >= @frameTime
      @frameAcum = 0
      @currentFrame += 1
      @currentFrame %= @maxFrames
    end

    if @state != SPRITE_STATE_TO_BE_REMOVED
      @timeSpanAcum += delta
      if @timeSpanAcum >= @timeSpan
        @state = SPRITE_STATE_TO_BE_REMOVED
      end
    end

    @pos.x = @pos.x + @vel.x * delta
    @pos.y = @pos.y + @vel.y * delta

    @vel.y += GameWorld.gravity

    updateCollisionProbes
  end

  def draw
    dir = @facingDirection == DIRECTION_RIGHT ? 'R' : 'L'
    DrawTexture(ResourceManager.textures["fireball#{@currentFrame}#{dir}"], @pos.x, @pos.y, WHITE)

    if GameWorld.debug
      @cpN.draw
      @cpS.draw
      @cpE.draw
      @cpW.draw
    end
  end

  def updateCollisionProbes
    @cpN.setX(@pos.x + 2)
    @cpN.setY(@pos.y)
    @cpN.setWidth(@dim.x - 4)

    @cpS.setX(@pos.x + 2)
    @cpS.setY(@pos.y + @dim.y - @cpS.getHeight)
    @cpS.setWidth(@dim.x - 4)

    @cpE.setX(@pos.x + @dim.x)
    @cpE.setY(@pos.y + @dim.y / 2 - @cpE.getHeight / 2)

    @cpW.setX(@pos.x - @cpW.getWidth)
    @cpW.setY(@pos.y + @dim.y / 2 - @cpW.getHeight / 2)
  end
end
