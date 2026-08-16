class Tile < Sprite
  attr_accessor :key, :visible, :onlyBaddies, :showCollisionOnDebug, :type

  def initialize(pos, dim, color, key, visible, type = TILE_TYPE_SOLID)
    super(pos, dim, color)
    @key = key
    @visible = visible
    @type = type
    @onlyBaddies = false
    @showCollisionOnDebug = false
  end

  def update
  end

  def draw
    if @visible
      textures = ResourceManager.textures

      if @key && @key.length != 0
        DrawTexture(textures[@key], @pos.x, @pos.y, WHITE)
      else
        case @type
        when TILE_TYPE_SOLID, TILE_TYPE_NON_SOLID, TILE_TYPE_SOLID_FROM_ABOVE
          DrawRectangle(@pos.x, @pos.y, @dim.x, @dim.y, @color)
        when TILE_TYPE_SLOPE_UP
          DrawTriangle(
            Vector2.create(@pos.x + @dim.x, @pos.y + @dim.y),
            Vector2.create(@pos.x + @dim.x, @pos.y),
            Vector2.create(@pos.x, @pos.y + @dim.y),
            @color
          )
        when TILE_TYPE_SLOPE_DOWN
          DrawTriangle(
            Vector2.create(@pos.x + @dim.x, @pos.y + @dim.y),
            Vector2.create(@pos.x, @pos.y),
            Vector2.create(@pos.x, @pos.y + @dim.y),
            @color
          )
        end
      end
    end

    if GameWorld.debug && @color.a != 0
      DrawRectangle(@pos.x, @pos.y, @dim.x, @dim.y, Fade(@color, 0.5))
    end
  end

  def isOnlyBaddies
    @onlyBaddies
  end

  def getType
    @type
  end
end
