class Baddie < Sprite
  attr_accessor :dyingFrameAcum, :dyingFrameTime, :maxDyingFrames, :currentDyingFrame,
                :pointsFrameAcum, :pointsFrameTime, :posOnDying

  def initialize(*args)
    pos = args[0] || Vector2.create(0, 0)
    dim = args[1] || Vector2.create(0, 0)
    has_vel = args[2].is_a?(Vector2)

    if has_vel
      vel = args[2]
      color = args[3] || BLACK
      rest = args[4..] || []
    else
      vel = Vector2.create(0, 0)
      color = args[2] || BLACK
      rest = args[3..] || []
    end

    frameTime = 0
    maxFrames = 0
    hitsToDie = 0
    earnedPoints = 0

    case rest.size
    when 2 then frameTime, maxFrames = rest
    when 4 then frameTime, maxFrames, hitsToDie, earnedPoints = rest
    end

    super(pos, dim, vel, color, frameTime, maxFrames, DIRECTION_LEFT, hitsToDie, earnedPoints)

    @dyingFrameAcum = 0.0
    @dyingFrameTime = 0.1
    @maxDyingFrames = 4
    @currentDyingFrame = 0
    @pointsFrameAcum = 0.0
    @pointsFrameTime = 1.0
    @posOnDying = Vector2.create(0, 0)

    c = ColorFromHSV(GetRandomValue(0, 360), 1, 0.9)
    @cpN.color = c
    @cpS.color = c
    @cpE.color = c
    @cpW.color = c
  end

  def update
    raise NotImplementedError
  end

  def draw
    raise NotImplementedError
  end

  def activateWithMarioProximity(mario)
    if CheckCollisionPointRec(
         Vector2.create(@pos.x + @dim.x / 2, @pos.y + @dim.y / 2),
         Rectangle.create(
           mario.getX + mario.getWidth / 2 - mario.getActivationWidth / 2,
           mario.getY + mario.getHeight / 2 - mario.getActivationWidth / 2,
           mario.getActivationWidth,
           mario.getActivationWidth
         )
       )
      @state = SPRITE_STATE_ACTIVE
    end
  end

  def setAttributesOnDying
    @vel.x = GetRandomValue(0, 1) == 0 ? 200 : -200
    @vel.y = -200
  end

  def onSouthCollision
  end

  def onHit
    @state = SPRITE_STATE_DYING
    @posOnDying = Vector2.create(@pos.x, @pos.y)
  end

  def followTheLeader(sprite)
  end
end
