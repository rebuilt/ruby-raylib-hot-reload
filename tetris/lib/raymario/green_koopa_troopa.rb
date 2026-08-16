class GreenKoopaTroopa < Baddie
  include Raylib

  def initialize(pos, dim, vel, color)
    super(pos, dim, vel, color, 0.2, 2, 1, 200)
  end

  def update
    delta = GetFrameTime

    if @state == SPRITE_STATE_ACTIVE
      @frameAcum += delta
      if @frameAcum >= @frameTime
        @frameAcum = 0
        @currentFrame += 1
        @currentFrame %= @maxFrames
      end

      @facingDirection = @vel.x >= 0 ? DIRECTION_RIGHT : DIRECTION_LEFT

      @pos.x += @vel.x * delta
      @pos.y += @vel.y * delta

      @vel.y += GameWorld.gravity
    elsif @state == SPRITE_STATE_DYING
      @dyingFrameAcum += delta
      if @dyingFrameAcum >= @dyingFrameTime
        @dyingFrameAcum = 0
        @currentDyingFrame += 1
        if @currentDyingFrame == @maxDyingFrames
          @state = SPRITE_STATE_TO_BE_REMOVED
        end
      end

      @pointsFrameAcum += delta
      if @pointsFrameAcum >= @pointsFrameTime
        @pointsFrameAcum = @pointsFrameTime
      end
    end

    updateCollisionProbes
  end

  def draw
    textures = ResourceManager.textures

    if @state == SPRITE_STATE_ACTIVE
      dir = @facingDirection == DIRECTION_RIGHT ? 'R' : 'L'
      DrawTexturePro(textures["greenKoopaTroopa#{@currentFrame}#{dir}"],
                     Rectangle.create(0, 0, @dim.x, @dim.y),
                     Rectangle.create(@pos.x + @dim.x / 2, @pos.y + @dim.y / 2, @dim.x, @dim.y),
                     Vector2.create(@dim.x / 2, @dim.y / 2), @angle, WHITE)
    elsif @state == SPRITE_STATE_DYING
      DrawTexture(textures["puft#{@currentDyingFrame}"], @pos.x, @pos.y, WHITE)
      pointsStr = "guiPoints#{@earnedPoints}"
      DrawTexture(textures[pointsStr],
                  @pos.x + @dim.x / 2 - textures[pointsStr].width / 2,
                  @pos.y - textures[pointsStr].height - (50 * @pointsFrameAcum / @pointsFrameTime),
                  WHITE)
    end

    if GameWorld.debug
      @cpN.draw
      @cpS.draw
      @cpE.draw
      @cpW.draw
    end
  end
end
