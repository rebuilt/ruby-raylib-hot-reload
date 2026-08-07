class Star < Item
  include Raylib

  def initialize(pos, dim, vel, color)
    super(pos, dim, vel, color, 0, 0, 1000)
  end

  def update
    delta = GetFrameTime

    if @state == SPRITE_STATE_ACTIVE
      if @facingDirection == DIRECTION_RIGHT
        @pos.x += @vel.x * delta
      else
        @pos.x -= @vel.x * delta
      end

      @pos.y += @vel.y * delta

      @vel.y += GameWorld.gravity
    elsif @state == SPRITE_STATE_HIT
      @onHitFrameAcum += delta
      if @onHitFrameAcum >= @onHitFrameTime
        @onHitFrameAcum = 0
        @state = SPRITE_STATE_TO_BE_REMOVED
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

    if @state == SPRITE_STATE_ACTIVE || @state == SPRITE_STATE_IDLE
      DrawTexture(textures["star"], @pos.x, @pos.y, WHITE)
    elsif @state == SPRITE_STATE_HIT
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

  def playCollisionSound
  end

  def updateMario(mario)
    mario.setInvincible(true)
  end

  def onSouthCollision(mario)
    @vel.y = -400
  end
end
