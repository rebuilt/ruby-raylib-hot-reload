class Coin < Item
  include Raylib

  def initialize(pos, dim, color)
    super(pos, dim, color, 0.1, 4, 200)
    @onHitFrameTime = 0.1
    @maxOnHitFrame = 4
  end

  def update
    delta = GetFrameTime

    @frameAcum += delta
    if @frameAcum >= @frameTime
      @frameAcum = 0
      @currentFrame += 1
      @currentFrame %= @maxFrames
    end

    if @state == SPRITE_STATE_HIT
      @onHitFrameAcum += delta
      if @onHitFrameAcum >= @onHitFrameTime
        @onHitFrameAcum = 0
        @currentOnHitFrame += 1
        if @currentOnHitFrame == @maxOnHitFrame
          @state = SPRITE_STATE_TO_BE_REMOVED
        end
      end

      @pointsFrameAcum += delta
      if @pointsFrameAcum >= @pointsFrameTime
        @pointsFrameAcum = @pointsFrameTime
      end
    end
  end

  def draw
    textures = ResourceManager.textures

    if @state == SPRITE_STATE_ACTIVE || @state == SPRITE_STATE_IDLE
      DrawTexture(textures["coin#{@currentFrame}"], @pos.x, @pos.y, WHITE)
    elsif @state == SPRITE_STATE_HIT
      DrawTexture(textures["stardust#{@currentOnHitFrame}"], @pos.x, @pos.y, WHITE)
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
    PlaySound(ResourceManager.sounds["coin"])
  end

  def updateMario(mario)
    mario.addCoins(1)
    mario.addPoints(@earnedPoints)
    if mario.getCoins >= 100
      mario.addLives(1)
      mario.setCoins(mario.getCoins - 100)
      PlaySound(ResourceManager.sounds["1up"])
    end
  end

  def checkCollision(sprite)
    CheckCollisionRecs(getRect, sprite.getRect) ? COLLISION_TYPE_COLLIDED : COLLISION_TYPE_NONE
  end
end
