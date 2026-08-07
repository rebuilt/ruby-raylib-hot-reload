class CollisionProbe
  include Raylib

  attr_accessor :pos, :dim, :color

  def initialize(pos = Vector2.create(0, 0), dim = Vector2.create(5, 5), color = Color.from_u8(255, 255, 255, 255))
    @pos = pos
    @dim = dim
    @color = color
  end

  def draw
    DrawRectangle(@pos.x, @pos.y, @dim.x, @dim.y, @color)
  end

  def checkCollision(rect)
    CheckCollisionRecs(rect, getRect) ? COLLISION_TYPE_COLLIDED : COLLISION_TYPE_NONE
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

  def setColor(color)
    @color = color
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

  def getDim
    @dim
  end

  def getWidth
    @dim.x
  end

  def getHeight
    @dim.y
  end

  def getColor
    @color
  end

  def getRect
    Rectangle.create(@pos.x, @pos.y, @dim.x, @dim.y)
  end
end
