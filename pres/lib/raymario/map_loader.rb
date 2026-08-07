module MapLoader
  include Raylib
  TILE_SIZE = 40

  def self.load(path)
    file = File.read(path)
    lines = file.lines.map(&:chomp)

    header = {}
    grid_lines = []

    lines.each do |line|
      if line.start_with?('#')
        next
      elsif line.start_with?('c:') || line.start_with?('b:') || line.start_with?('t:') ||
            line.start_with?('m:') || line.start_with?('f:') || line.start_with?('h:')
        key, value = line.split(':', 2)
        header[key.strip] = value.strip
      else
        grid_lines << line
      end
    end

    max_width = grid_lines.map(&:length).max || 0
    height = grid_lines.length

    map_width = max_width * TILE_SIZE
    map_height = height * TILE_SIZE

    tiles = []
    blocks = []
    baddies = []
    items = []

    grid_lines.each_with_index do |row, y|
      row.chars.each_with_index do |ch, x|
        pos_x = x * TILE_SIZE
        pos_y = y * TILE_SIZE
        dim = Vector2.create(TILE_SIZE, TILE_SIZE)

        case ch
        when ' '
          # empty
        when '/'
          tiles << Tile.new(Vector2.create(pos_x, pos_y), dim, Color.from_u8(0, 0, 0, 0), "", false)
        when '|'
          tile = Tile.new(Vector2.create(pos_x, pos_y), dim, Color.from_u8(0, 0, 0, 0), "", false)
          tile.onlyBaddies = true
          tiles << tile
        when 's'
          blocks << StoneBlock.new(Vector2.create(pos_x, pos_y), dim, Color.from_u8(0, 0, 0, 0))
        when 'w'
          blocks << WoodBlock.new(Vector2.create(pos_x, pos_y), dim, Color.from_u8(0, 0, 0, 0))
        when 'g'
          blocks << GlassBlock.new(Vector2.create(pos_x, pos_y), dim, Color.from_u8(0, 0, 0, 0))
        when 'c'
          blocks << CloudBlock.new(Vector2.create(pos_x, pos_y), dim, Color.from_u8(0, 0, 0, 0))
        when 'i'
          blocks << EyesClosedBlock.new(Vector2.create(pos_x, pos_y), dim, Color.from_u8(0, 0, 0, 0))
        when 'y'
          blocks << EyesOpenedBlock.new(Vector2.create(pos_x, pos_y), dim, Color.from_u8(0, 0, 0, 0))
        when 'v'
          blocks << InvisibleBlock.new(Vector2.create(pos_x, pos_y), dim, Color.from_u8(0, 0, 0, 0))
        when 'h'
          blocks << MessageBlock.new(Vector2.create(pos_x, pos_y), dim, Color.from_u8(0, 0, 0, 0))
        when '?'
          blocks << QuestionBlock.new(Vector2.create(pos_x, pos_y), dim, Color.from_u8(0, 0, 0, 0))
        when '!'
          blocks << ExclamationBlock.new(Vector2.create(pos_x, pos_y), dim, Color.from_u8(0, 0, 0, 0))
        when 'm'
          blocks << QuestionMushroomBlock.new(Vector2.create(pos_x, pos_y), dim, Color.from_u8(0, 0, 0, 0))
        when 'f'
          blocks << QuestionFireFlowerBlock.new(Vector2.create(pos_x, pos_y), dim, Color.from_u8(0, 0, 0, 0))
        when 'u'
          blocks << QuestionOneUpMushroomBlock.new(Vector2.create(pos_x, pos_y), dim, Color.from_u8(0, 0, 0, 0))
        when '+'
          blocks << QuestionThreeUpMoonBlock.new(Vector2.create(pos_x, pos_y), dim, Color.from_u8(0, 0, 0, 0))
        when '*'
          blocks << QuestionStarBlock.new(Vector2.create(pos_x, pos_y), dim, Color.from_u8(0, 0, 0, 0))
        when 'o'
          items << Coin.new(Vector2.create(pos_x + 4, pos_y + 4), Vector2.create(32, 32), WHITE)
        when ':'
          items << YoshiCoin.new(Vector2.create(pos_x + 4, pos_y + 4), Vector2.create(32, 32), WHITE)
        when '='
          items << CourseClearToken.new(Vector2.create(pos_x + 4, pos_y + 4), Vector2.create(32, 32), WHITE)
        when '1'
          baddies << Goomba.new(Vector2.create(pos_x, pos_y), dim, Vector2.create(40, 0))
        when 'A'..'Z'
          key = ch
          tiles << Tile.new(Vector2.create(pos_x, pos_y), dim, WHITE, "tile#{key}", true)
        when '{', '[', '}', ']'
          tiles << Tile.new(Vector2.create(pos_x, pos_y), dim, WHITE, "", false)
        when '2'..'9', '@', '$', '%', '&', '~', '^', '<', '.'
          baddies << Goomba.new(Vector2.create(pos_x, pos_y), dim, Vector2.create(40, 0))
        end
      end
    end

    {
      tiles: tiles,
      blocks: blocks,
      baddies: baddies,
      items: items,
      mapWidth: map_width,
      mapHeight: map_height,
      backgroundColor: header['c'],
      backgroundId: header['b'],
      musicId: header['m'],
      message: header['h']
    }
  end
end
