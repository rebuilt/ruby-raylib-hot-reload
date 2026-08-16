class Block < Sprite
  attr_accessor :hit

  def initialize(*args)
    pos = args[0] || Vector2.create(0, 0)
    dim = args[1] || Vector2.create(0, 0)
    color = args[2] || BLACK
    rest = args[3..] || []

    if args.empty?
      frameTime = 0
      maxFrames = 0
      earnedPoints = 0
    else
      frameTime = 0
      maxFrames = 1
      earnedPoints = 0

      case rest.size
      when 2 then frameTime, maxFrames = rest
      when 3 then frameTime, maxFrames, earnedPoints = rest
      end
    end

    super(pos, dim, Vector2.create(0, 0), color, frameTime, maxFrames, DIRECTION_RIGHT, 0, earnedPoints)
    @hit = false
  end

  def update
    raise NotImplementedError
  end

  def draw
    textures = ResourceManager.textures
    return unless @textureKey && textures[@textureKey]

    tex = textures[@textureKey]
    x = @pos.x
    y = @pos.y
    w = @dim.x
    h = @dim.y

    tiles_x = (w / tex.width.to_f).ceil
    tiles_y = (h / tex.height.to_f).ceil

    (0...tiles_y).each do |ty|
      (0...tiles_x).each do |tx|
        src = Rectangle.create(0, 0, tex.width, tex.height)
        dst = Rectangle.create(x + tx * tex.width + tex.width / 2, y + ty * tex.height + tex.height / 2, tex.width, tex.height)
        origin = Vector2.create(tex.width / 2, tex.height / 2)
        DrawTexturePro(tex, src, dst, origin, 0, WHITE)
      end
    end
  end

  def doHit(mario, map)
  end

  def resetHit
    @hit = false
  end
end
