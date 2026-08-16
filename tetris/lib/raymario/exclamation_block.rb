class ExclamationBlock < Block
  include Raylib

  attr_accessor :coinAnimationTime, :coinAnimationAcum, :coinAnimationFrame, :coinAnimationRunning,
                :coinY, :coinVelY, :stardustAnimationTime, :stardustAnimationAcum,
                :stardustAnimationFrame, :maxStartDustAnimationFrame, :stardustAnimationRunning,
                :pointsFrameAcum, :pointsFrameTime, :pointsAnimationRunning

  def initialize(pos, dim, color, frameTime = 0.1, maxFrames = 4)
    super(pos, dim, color, frameTime, maxFrames, 10)

    @coinAnimationTime = 0.6
    @coinAnimationAcum = 0.0
    @coinAnimationFrame = 0
    @coinAnimationRunning = false
    @coinY = 0.0
    @coinVelY = -400.0

    @stardustAnimationTime = 0.1
    @stardustAnimationAcum = 0.0
    @stardustAnimationFrame = 0
    @maxStartDustAnimationFrame = 4
    @stardustAnimationRunning = false

    @pointsFrameAcum = 0.0
    @pointsFrameTime = 0.5
    @pointsAnimationRunning = false
  end

  def update
    delta = GetFrameTime

    if @hit && @coinAnimationRunning
      @coinAnimationAcum += delta
      if @coinAnimationAcum >= @coinAnimationTime
        @coinAnimationRunning = false
        @stardustAnimationRunning = true
        @pointsAnimationRunning = true
      end

      @frameAcum += delta
      if @frameAcum > @frameTime
        @frameAcum = 0
        @coinAnimationFrame += 1
        @coinAnimationFrame %= @maxFrames
      end

      @coinY += @coinVelY * delta
      @coinVelY += GameWorld.gravity
    end

    if @stardustAnimationRunning
      @stardustAnimationAcum += delta
      if @stardustAnimationAcum >= @stardustAnimationTime
        @stardustAnimationAcum = 0
        @stardustAnimationFrame += 1
        if @stardustAnimationFrame == @maxStartDustAnimationFrame
          @stardustAnimationRunning = false
        end
      end
    end

    if @pointsAnimationRunning
      @pointsFrameAcum += delta
      if @pointsFrameAcum >= @pointsFrameTime
        @pointsAnimationRunning = false
      end
    end
  end

  def draw
    textures = ResourceManager.textures

    if @coinAnimationRunning
      DrawTexture(textures["coin#{@coinAnimationFrame}"], @pos.x + 4, @coinY, WHITE)
    end

    if @stardustAnimationRunning
      DrawTexture(textures["stardust#{@stardustAnimationFrame}"], @pos.x, @pos.y - @dim.y, WHITE)
    end

    if @pointsAnimationRunning
      pointsStr = "guiPoints#{@earnedPoints}"
      DrawTexture(textures[pointsStr],
                  @pos.x + @dim.x / 2 - textures[pointsStr].width / 2,
                  @pos.y - @dim.y / 2 - textures[pointsStr].height - (20 * @pointsFrameAcum / @pointsFrameTime),
                  WHITE)
    end

    if @hit
      DrawTexture(textures["blockEyesClosed"], @pos.x, @pos.y, WHITE)
    else
      DrawTexture(textures["blockExclamation"], @pos.x, @pos.y, WHITE)
    end

    if GameWorld.debug && @color.a != 0
      DrawRectangle(@pos.x, @pos.y, @dim.x, @dim.y, Fade(@color, 0.5))
    end
  end

  def doHit(mario, map)
    unless @hit
      PlaySound(ResourceManager.sounds["coin"])
      @hit = true
      @coinAnimationRunning = true
      @coinY = @pos.y
      mario.addCoins(1)
      mario.addPoints(@earnedPoints)
    end
  end
end
