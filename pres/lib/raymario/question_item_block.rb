class QuestionItemBlock < Block
  include Raylib

  attr_accessor :item, :itemVelY, :itemMinY, :map

  def initialize(pos, dim, color, frameTime = 0.1, maxFrames = 4)
    super(pos, dim, color, frameTime, maxFrames)

    @item = nil
    @itemVelY = -80.0
    @itemMinY = 0.0
    @map = nil
  end

  def createItem(mario)
    raise NotImplementedError
  end

  def update
    delta = GetFrameTime

    unless @hit
      @frameAcum += delta
      if @frameAcum >= @frameTime
        @frameAcum = 0
        @currentFrame += 1
        @currentFrame %= @maxFrames
      end
    end

    unless @item.nil?
      @item.setY(@item.getY + @itemVelY * delta)
      if @item.getY <= @itemMinY
        @item.setY(@itemMinY)
        @item.setState(SPRITE_STATE_ACTIVE)
        @map.items << @item
        @item = nil
      end
    end
  end

  def draw
    @item.draw unless @item.nil?

    if @hit
      DrawTexture(ResourceManager.textures["blockEyesClosed"], @pos.x, @pos.y, WHITE)
    else
      DrawTexture(ResourceManager.textures["blockQuestion#{@currentFrame}"], @pos.x, @pos.y, WHITE)
    end

    if GameWorld.debug && @color.a != 0
      DrawRectangle(@pos.x, @pos.y, @dim.x, @dim.y, Fade(@color, 0.5))
    end
  end

  def doHit(mario, map)
    unless @hit
      PlaySound(ResourceManager.sounds["powerUpAppears"])
      @hit = true
      @item = createItem(mario)
      @item.setFacingDirection(mario.getFacingDirection)
      @itemMinY = @pos.y - 32
      @map = map
    end
  end
end
