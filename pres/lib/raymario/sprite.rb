require_relative "enums"
require_relative "collision_probe"

DEBUG = false

class Sprite
  include Raylib

  attr_accessor :pos, :dim, :vel, :angle, :hitsToDie, :earnedPoints, :color,
                :state, :auxiliaryState, :frameTime, :frameAcum, :currentFrame,
                :maxFrames, :facingDirection, :cpN, :cpS, :cpE, :cpW,
                :textureKey, :marioSize

  def initialize(*args)
    pos = args[0] || Vector2.create(0, 0)
    dim = args[1] || Vector2.create(0, 0)
    has_vel = args[2].is_a?(Vector2)

    if has_vel
      vel = args[2]
      fourth = args[3] || BLACK
      rest = args[4..] || []

      frameTime = 0
      maxFrames = 0
      hitsToDie = args.empty? ? 0 : 1
      facingDirection = DIRECTION_RIGHT
      earnedPoints = 0

      case rest.size
      when 1 then hitsToDie = rest[0]
      when 2 then frameTime, maxFrames = rest
      when 3 then frameTime, maxFrames, facingDirection = rest
      when 4 then frameTime, maxFrames, facingDirection, hitsToDie = rest
      when 5 then frameTime, maxFrames, facingDirection, hitsToDie, earnedPoints = rest
      end
    else
      vel = Vector2.create(0, 0)
      fourth = args[2] || BLACK
      rest = args[3..] || []

      frameTime = 0
      maxFrames = 0
      hitsToDie = args.empty? ? 0 : 1
      facingDirection = DIRECTION_RIGHT
      earnedPoints = 0

      case rest.size
      when 1 then hitsToDie = rest[0]
      when 2 then frameTime, maxFrames = rest
      when 3 then frameTime, maxFrames, hitsToDie = rest
      when 4 then frameTime, maxFrames, facingDirection = rest
      when 5 then frameTime, maxFrames, facingDirection, hitsToDie = rest
      end
    end

    init_full(pos, dim, vel, fourth, frameTime, maxFrames, facingDirection, hitsToDie, earnedPoints)
  end

  def init_full(pos, dim, vel, fourth, frameTime, maxFrames, facingDirection, hitsToDie, earnedPoints)
    @pos = pos
    @dim = dim
    @vel = vel
    @angle = 0.0
    @hitsToDie = hitsToDie
    @earnedPoints = earnedPoints
    @color = fourth.is_a?(String) ? WHITE : fourth
    @textureKey = fourth.is_a?(String) ? fourth : nil
    @state = SPRITE_STATE_IDLE
    @auxiliaryState = SPRITE_STATE_NEITHER
    @frameTime = frameTime
    @frameAcum = 0.0
    @currentFrame = 0
    @maxFrames = maxFrames
    @facingDirection = facingDirection
    @marioSize = MARIO_SIZE_SMALL

    @cpN = CollisionProbe.new
    @cpS = CollisionProbe.new
    @cpE = CollisionProbe.new
    @cpW = CollisionProbe.new
    @cpN.color = @color
    @cpS.color = @color
    @cpE.color = @color
    @cpW.color = @color
  end

  def update
    delta = GetFrameTime
    if @state == SPRITE_STATE_WALKING && @maxFrames > 0
      @frameAcum += delta
      if @frameAcum >= @frameTime
        @frameAcum = 0
        @currentFrame += 1
        @currentFrame %= @maxFrames
      end
    end
  end

  def draw
    textures = ResourceManager.textures
    tex_key = mario_texture_key
    return unless tex_key && textures[tex_key]

    tex = textures[tex_key]
    src = Rectangle.create(0, 0, tex.width, tex.height)
    dst = Rectangle.create(@pos.x + @dim.x / 2, @pos.y + @dim.y / 2, @dim.x, @dim.y)
    origin = Vector2.create(@dim.x / 2, @dim.y / 2)
    DrawTexturePro(tex, src, dst, origin, @angle, WHITE)
  end

  def mario_texture_key
    return "smallMario0Dy" if @state == SPRITE_STATE_DYING
    return "smallMario0Vic" if @state == SPRITE_STATE_VICTORY

    dir = @facingDirection == DIRECTION_RIGHT ? "R" : "L"
    size = @marioSize == MARIO_SIZE_SMALL ? "smallMario" : "superMario"

    case @state
    when SPRITE_STATE_WALKING
      "#{size}#{@currentFrame}Ru#{dir}"
    when SPRITE_STATE_JUMPING
      if @vel.x.abs > 50
        "#{size}0JuRu#{dir}"
      else
        "#{size}0Ju#{dir}"
      end
    when SPRITE_STATE_FALLING
      "#{size}0Fa#{dir}"
    when SPRITE_STATE_LOOK_UP
      "#{size}0Lu#{dir}"
    when SPRITE_STATE_DUCKING
      "#{size}0Du#{dir}"
    else
      "#{size}#{@currentFrame}#{dir}"
    end
  end

  def checkCollision(sprite)
    if @state != SPRITE_STATE_NO_COLLIDABLE &&
       @auxiliaryState != SPRITE_STATE_NO_COLLIDABLE &&
       sprite.state != SPRITE_STATE_NO_COLLIDABLE &&
       sprite.auxiliaryState != SPRITE_STATE_NO_COLLIDABLE
      rect = sprite.getRect

      if @cpN.checkCollision(rect)
        sprite.color = @cpN.color if DEBUG
        return COLLISION_TYPE_NORTH
      elsif @cpS.checkCollision(rect)
        sprite.color = @cpS.color if DEBUG
        return COLLISION_TYPE_SOUTH
      elsif @cpE.checkCollision(rect)
        sprite.color = @cpE.color if DEBUG
        return COLLISION_TYPE_EAST
      elsif @cpW.checkCollision(rect)
        sprite.color = @cpW.color if DEBUG
        return COLLISION_TYPE_WEST
      end
    end

    COLLISION_TYPE_NONE
  end

  def updateCollisionProbes
    @cpN.setX(@pos.x + @dim.x / 2 - @cpN.getWidth / 2)
    @cpN.setY(@pos.y)

    @cpS.setX(@pos.x + @dim.x / 2 - @cpS.getWidth / 2)
    @cpS.setY(@pos.y + @dim.y - @cpS.getHeight)

    @cpE.setX(@pos.x + @dim.x - @cpE.getWidth)
    @cpE.setY(@pos.y + @dim.y / 2 - @cpE.getHeight / 2)

    @cpW.setX(@pos.x)
    @cpW.setY(@pos.y + @dim.y / 2 - @cpW.getHeight / 2)
  end

  def setPos(a, b = nil)
    if b.nil?
      @pos = a
    else
      @pos.x = a
      @pos.y = b
    end
  end

  def setX(x)
    @pos.x = x
  end

  def setY(y)
    @pos.y = y
  end

  def setDim(a, b = nil)
    if b.nil?
      @dim = a
    else
      @dim.x = a
      @dim.y = b
    end
  end

  def setWidth(width)
    @dim.x = width
  end

  def setHeight(height)
    @dim.y = height
  end

  def setVel(a, b = nil)
    if b.nil?
      @vel = a
    else
      @vel.x = a
      @vel.y = b
    end
  end

  def setVelX(velX)
    @vel.x = velX
  end

  def setVelY(velY)
    @vel.y = velY
  end

  def setAngle(angle)
    @angle = angle
  end

  def setColor(color)
    @color = color
  end

  def setState(state)
    @state = state
  end

  def setAuxiliaryState(auxiliaryState)
    @auxiliaryState = auxiliaryState
  end

  def setFacingDirection(facingDirection)
    @facingDirection = facingDirection
  end

  def getPos
    @pos
  end

  def getX
    @pos.x
  end

  def getY
    @pos.y
  end

  def getCenter
    Vector2.create(@pos.x + @dim.x / 2, @pos.y + @dim.y / 2)
  end

  def getDim
    @dim
  end

  def getWidth
    @dim.x
  end

  def getHeight
    @dim.y
  end

  def getVel
    @vel
  end

  def getVelX
    @vel.x
  end

  def getVelY
    @vel.y
  end

  def getAngle
    @angle
  end

  def getEarnedPoints
    @earnedPoints
  end

  def getColor
    @color
  end

  def getState
    @state
  end

  def getActivationWidth
    200.0
  end

  def getAuxiliaryState
    @auxiliaryState
  end

  def getFacingDirection
    @facingDirection
  end

  def getRect
    Rectangle.create(@pos.x, @pos.y, @dim.x, @dim.y)
  end
end
