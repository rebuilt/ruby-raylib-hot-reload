class FireFlower < Item
  include Raylib

  attr_accessor :doCollisionOnGround, :blinking, :blinkingAcum, :blinkingTime, :doBlink

  def initialize(pos, dim, color, vel = Vector2.create(0, 0), doCollisionOnGround = false, blinking = false)
    super(pos, dim, vel, color, 0.2, 2, 1000)

    @doCollisionOnGround = doCollisionOnGround
    @blinking = blinking
    @blinkingAcum = 0.0
    @blinkingTime = 0.1
    @doBlink = false

    @pauseGameOnHit = true
  end

  def update
    delta = GetFrameTime

    @frameAcum += delta
    if @frameAcum >= @frameTime
      @frameAcum = 0
      @currentFrame += 1
      @currentFrame %= @maxFrames
    end

    if @state == SPRITE_STATE_ACTIVE
      @pos.y += @vel.y * delta

      if @blinking
        @blinkingAcum += delta
        if @blinkingAcum >= @blinkingTime
          @blinkingAcum = 0
          @doBlink = !@doBlink
        end
      end
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
  end

  def draw
    textures = ResourceManager.textures

    if @state == SPRITE_STATE_ACTIVE || @state == SPRITE_STATE_IDLE
      DrawTexture(textures["fireFlower#{@currentFrame}"], @pos.x, @pos.y, WHITE) unless @doBlink
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
    PlaySound(ResourceManager.sounds["powerUp"])
  end

  def updateMario(mario)
    mario.addPoints(@earnedPoints)

    case mario.getType
    when MARIO_TYPE_SMALL
      mario.setY(mario.getY - 16)
      mario.setLastStateBeforeTransition(mario.getState)
      mario.setState(SPRITE_STATE_TRANSITIONING_SMALL_TO_FLOWER)
    when MARIO_TYPE_SUPER
      mario.setLastStateBeforeTransition(mario.getState)
      mario.setState(SPRITE_STATE_TRANSITIONING_SUPER_TO_FLOWER)
      case mario.getReservedPowerUp
      when MARIO_TYPE_SMALL
        mario.setReservedPowerUp(MARIO_TYPE_SUPER)
        PlaySound(ResourceManager.sounds["reserveItemStore"])
      when MARIO_TYPE_SUPER
      when MARIO_TYPE_FLOWER
      end
    when MARIO_TYPE_FLOWER
      case mario.getReservedPowerUp
      when MARIO_TYPE_SMALL
        mario.setReservedPowerUp(MARIO_TYPE_FLOWER)
        PlaySound(ResourceManager.sounds["reserveItemStore"])
      when MARIO_TYPE_SUPER
        mario.setReservedPowerUp(MARIO_TYPE_FLOWER)
        PlaySound(ResourceManager.sounds["reserveItemStore"])
      when MARIO_TYPE_FLOWER
      end
      mario.getGameWorld.unpauseGame
    end
  end

  def onSouthCollision(mario)
    if @doCollisionOnGround
      @blinking = false
      @doBlink = false
      @doCollisionOnGround = false
    end
  end
end
