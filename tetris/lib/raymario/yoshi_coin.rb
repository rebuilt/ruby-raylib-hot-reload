class YoshiCoin < Item
  include Raylib

  attr_accessor :countingUp

  def initialize(pos, dim, color)
    super(pos, dim, color, 0.1, 4, 1000)
    @countingUp = true
    @onHitFrameTime = 0.1
    @maxOnHitFrame = 4
  end

  def update
    delta = GetFrameTime

    @frameAcum += delta

    if @frameAcum >= @frameTime
      @frameAcum = 0

      if @countingUp
        @currentFrame += 1
        if @currentFrame == @maxFrames
          @currentFrame = 2
          @countingUp = false
        end
      else
        @currentFrame -= 1
        if @currentFrame == 0
          @countingUp = true
        end
      end
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
      DrawTexture(textures["yoshiCoin#{@currentFrame}"], @pos.x, @pos.y, WHITE)
    elsif @state == SPRITE_STATE_HIT
      DrawTexture(textures["stardust#{@currentOnHitFrame}"], @pos.x, @pos.y, WHITE)
      DrawTexture(textures["stardust#{@currentOnHitFrame}"], @pos.x, @pos.y + 20, WHITE)
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
    PlaySound(ResourceManager.sounds["dragonCoin"])
  end

  def updateMario(mario)
    mario.addYoshiCoins(1)
    mario.addPoints(@earnedPoints)
    if mario.getYoshiCoins == 5
      mario.addLives(1)
      mario.setYoshiCoins(0)
      PlaySound(ResourceManager.sounds["1up"])
    end
  end

  def checkCollision(sprite)
    CheckCollisionRecs(getRect, sprite.getRect) ? COLLISION_TYPE_COLLIDED : COLLISION_TYPE_NONE
  end
end
