module Utils
  extend self
  include Raylib

  def toRadians(degrees)
    degrees * Math::PI / 180.0
  end

  def toDegrees(radians)
    radians * 180.0 / Math::PI
  end

  def texture2DFlipHorizontal(texture)
    img = LoadImageFromTexture(texture)
    ImageFlipHorizontal(img.pointer)
    newTexture = LoadTextureFromImage(img)
    UnloadImage(img)
    newTexture
  end

  def textureColorReplace(texture, targetColor, newColor)
    img = LoadImageFromTexture(texture)
    ImageColorReplace(img.pointer, targetColor, newColor)
    newTexture = LoadTextureFromImage(img)
    UnloadImage(img)
    newTexture
  end

  def textureColorReplacePallete(texture, replacePallete)
    img = LoadImageFromTexture(texture)
    i = 0
    while i < replacePallete.size
      ImageColorReplace(img.pointer, replacePallete[i], replacePallete[i + 1])
      i += 2
    end
    newTexture = LoadTextureFromImage(img)
    UnloadImage(img)
    newTexture
  end

  def drawWhiteSmallNumber(number, x, y)
    drawSmallNumber(number, x, y, "guiNumbersWhite")
  end

  def drawYellowSmallNumber(number, x, y)
    drawSmallNumber(number, x, y, "guiNumbersYellow")
  end

  def drawSmallNumber(number, x, y, textureId)
    texture = ResourceManager.textures[textureId]
    w = 18
    h = 14
    str = number.to_s
    px = x
    str.each_char do |i|
      DrawTextureRec(texture, Rectangle.create((i.ord - 48) * w, 0, w, h), Vector2.create(px, y), WHITE)
      px += w - 2
    end
  end

  def drawBigNumber(number, x, y)
    texture = ResourceManager.textures["guiNumbersBig"]
    w = 18
    h = 28
    str = number.to_s
    px = x
    str.each_char do |i|
      DrawTextureRec(texture, Rectangle.create((i.ord - 48) * w, 0, w, h), Vector2.create(px, y), WHITE)
      px += w - 2
    end
  end

  def drawString(str, x, y)
    texture = ResourceManager.textures["guiAlfa"]
    w = 18
    h = 20
    px = x
    str.each_char do |i|
      code = i.upcase.ord
      space = false
      textureY = nil
      undefined = false

      if code >= 48 && code <= 57
        code -= 48
        textureY = 0
      elsif code >= 65 && code <= 90
        code -= 65
        textureY = 20
      else
        case i
        when '.' then code = 0
        when ',' then code = 1
        when '-' then code = 2
        when '!' then code = 3
        when '?' then code = 4
        when '=' then code = 5
        when ':' then code = 6
        when "'" then code = 7
        when '"' then code = 8
        when ' ' then space = true
        else undefined = true
        end
        textureY = 60
      end

      if undefined
        code = 4
        textureY = 60
      end

      unless space
        DrawTextureRec(texture, Rectangle.create(code * w, textureY, w, h), Vector2.create(px, y), WHITE)
      end

      px += w - 2
    end
  end

  def drawMessageString(str, x, y)
    texture = ResourceManager.textures["guiAlfaLowerUpper"]
    w = 16
    h = 16
    px = x
    str.each_char do |i|
      code = i.ord
      space = false
      textureY = nil
      undefined = false

      if code >= 48 && code <= 57
        code -= 48
        textureY = 0
      elsif code >= 65 && code <= 90
        code -= 65
        textureY = 16
      elsif code >= 97 && code <= 122
        code -= 97
        textureY = 32
      else
        case i
        when '.' then code = 0
        when ',' then code = 1
        when '-' then code = 2
        when '!' then code = 3
        when '?' then code = 4
        when '=' then code = 5
        when ':' then code = 6
        when "'" then code = 7
        when '"' then code = 8
        when '#' then code = 9
        when '(' then code = 10
        when ')' then code = 11
        when ' ' then space = true
        else undefined = true
        end
        textureY = 48
      end

      if undefined
        code = 4
        textureY = 48
      end

      unless space
        DrawTextureRec(texture, Rectangle.create(code * w, textureY, w, h), Vector2.create(px, y), WHITE)
      end

      px += w - 2
    end
  end

  def getSmallNumberWidth(number)
    16 * number.to_s.length
  end

  def getSmallNumberHeight
    14
  end

  def getBigNumberWidth(number)
    16 * number.to_s.length
  end

  def getBigNumberHeight
    28
  end

  def getDrawStringWidth(str)
    16 * str.length
  end

  def getDrawStringHeight
    20
  end

  def getDrawMessageStringWidth(str)
    14 * str.length
  end

  def getDrawMessageStringHeight
    16
  end

  def split(s, delimiter = "\n")
    res = []
    pos_start = 0
    delim_len = delimiter.length
    while (pos_end = s.index(delimiter, pos_start))
      res << s[pos_start, pos_end - pos_start]
      pos_start = pos_end + delim_len
    end
    res << s[pos_start..]
    res
  end
end
