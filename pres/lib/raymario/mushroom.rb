class Mushroom < Item
  include Raylib

  attr_accessor :applyGravity, :doCollisionOnGround, :blinking, :blinkingAcum, :blinkingTime, :doBlink

  def initialize(pos, dim, vel, color, applyGravity = true, doCollisionOnGround = false, blinking = false)
    super(pos, dim, vel, color, 0, 0, 1000)

    @applyGravity = applyGravity
    @doCollisionOnGround = doCollisionOnGround
    @blinking = blinking
    @blinkingAcum = 0.0
    @blinkingTime = 0.1
    @doBlink = false

    @pauseGameOnHit = true
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

      @vel.y += GameWorld.gravity if @applyGravity

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

    updateCollisionProbes
  end

  def draw
    textures = ResourceManager.textures

    if @state == SPRITE_STATE_ACTIVE || @state == SPRITE_STATE_IDLE
      DrawTexture(textures["mushroom"], @pos.x, @pos.y, WHITE) unless @doBlink
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
      mario.setState(SPRITE_STATE_TRANSITIONING_SMALL_TO_SUPER)
    when MARIO_TYPE_SUPER
      case mario.getReservedPowerUp
      when MARIO_TYPE_SMALL
        mario.setReservedPowerUp(MARIO_TYPE_SUPER)
        PlaySound(ResourceManager.sounds["reserveItemStore"])
      when MARIO_TYPE_SUPER
      when MARIO_TYPE_FLOWER
      end
      mario.getGameWorld.unpauseGame
    when MARIO_TYPE_FLOWER
      case mario.getReservedPowerUp
      when MARIO_TYPE_SMALL
        mario.setReservedPowerUp(MARIO_TYPE_SUPER)
        PlaySound(ResourceManager.sounds["reserveItemStore"])
      when MARIO_TYPE_SUPER
      when MARIO_TYPE_FLOWER
      end
      mario.getGameWorld.unpauseGame
    end
  end

  def onSouthCollision(mario)
    if @doCollisionOnGround
      @vel.x = 200
      @facingDirection = mario.getFacingDirection
      @blinking = false
      @doBlink = false
      @doCollisionOnGround = false
    end
  end
end
