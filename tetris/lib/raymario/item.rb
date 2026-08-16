class Item < Sprite
  attr_accessor :onHitFrameAcum, :onHitFrameTime, :maxOnHitFrame, :currentOnHitFrame,
                :pointsFrameAcum, :pointsFrameTime, :pauseGameOnHit

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
    earnedPoints = 0

    case rest.size
    when 1 then earnedPoints = rest[0]
    when 2 then frameTime, maxFrames = rest
    when 3 then frameTime, maxFrames, earnedPoints = rest
    end

    super(pos, dim, vel, color, frameTime, maxFrames, DIRECTION_RIGHT, 0, earnedPoints)

    @onHitFrameAcum = 0.0
    @onHitFrameTime = 1.0
    @maxOnHitFrame = 1
    @currentOnHitFrame = 0
    @pointsFrameAcum = 0.0
    @pointsFrameTime = 1.0
    @pauseGameOnHit = false
  end

  def update
    raise NotImplementedError
  end

  def draw
    raise NotImplementedError
  end

  def playCollisionSound
    raise NotImplementedError
  end

  def updateMario(mario)
    raise NotImplementedError
  end

  def onSouthCollision(mario)
  end

  def isPauseGameOnHit
    @pauseGameOnHit
  end
end
