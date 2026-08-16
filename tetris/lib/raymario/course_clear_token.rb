class CourseClearToken < Item
  include Raylib

  attr_accessor :minY, :maxY

  def initialize(pos, dim, color)
    super(pos, dim, color, 0, 0, 10000)
    @minY = @pos.y
    @maxY = @minY + 8 * @dim.y
    @vel.y = 100
    @onHitFrameTime = 0.1
    @maxOnHitFrame = 4
  end

  def update
    delta = GetFrameTime

    if @pos.y < @minY
      @pos.y = @minY
      @vel.y = -@vel.y
    elsif @pos.y > @maxY
      @pos.y = @maxY
      @vel.y = -@vel.y
    end

    @pos.y += @vel.y * delta

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
      DrawTexture(textures["courseClearToken"], @pos.x, @pos.y, WHITE)
    elsif @state == SPRITE_STATE_HIT
      DrawTexture(textures["stardust#{@currentOnHitFrame}"], @pos.x, @pos.y, WHITE)
      DrawTexture(textures["stardust#{@currentOnHitFrame}"], @pos.x + 32, @pos.y, WHITE)
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
    mario.addPoints(@earnedPoints)
    mario.setState(SPRITE_STATE_VICTORY)
  end

  def checkCollision(sprite)
    CheckCollisionRecs(getRect, sprite.getRect) ? COLLISION_TYPE_COLLIDED : COLLISION_TYPE_NONE
  end
end
