# 3D text drawing helpers.
#
# Translated from the raylib example "3d drawing" (examples/text/text_draw_3d.c)
# by Vlad Adrian (@demizdor).
#
# A 2D text is drawn in 3D space: each letter is drawn in a quad (or 2 quads if
# backface is set) whose texture coordinates map to the glyphs inside the font
# texture. Text wrapped in `~~...~~` gets a per-letter wavy effect applied.
module Threed
  LETTER_BOUNDRY_SIZE = 0.25 unless const_defined?(:LETTER_BOUNDRY_SIZE)
  TEXT_MAX_LAYERS = 32 unless const_defined?(:TEXT_MAX_LAYERS)
  LETTER_BOUNDRY_COLOR = Raylib::VIOLET unless const_defined?(:LETTER_BOUNDRY_COLOR)

  # Configuration structure for waving the text
  class WaveTextConfig
    attr_accessor :wave_range, :wave_speed, :wave_offset

    def initialize
      @wave_speed = Vector3.create(3.0, 3.0, 0.5)
      @wave_offset = Vector3.create(0.35, 0.35, 0.35)
      @wave_range = Vector3.create(0.45, 0.45, 0.45)
    end
  end

  # Alpha discard fragment shader (https://bedroomcoders.co.uk/posts/198).
  # Used to handle the depth buffer issue of the transparent font texture.
  ALPHA_DISCARD_FS = <<~GLSL unless const_defined?(:ALPHA_DISCARD_FS)
    #version 330
    in vec2 fragTexCoord;
    in vec4 fragColor;
    uniform sampler2D texture0;
    out vec4 finalColor;
    void main()
    {
        vec4 texelColor = texture(texture0, fragTexCoord);
        finalColor = texelColor * fragColor;
        if (finalColor.a < 0.1) discard;
    }
  GLSL

  def self.load_alpha_discard_shader
    LoadShaderFromMemory(nil, ALPHA_DISCARD_FS)
  end

  # Draw a codepoint in 3D space
  def self.draw_text_codepoint_3d(font, codepoint, position, font_size, backface, tint,
                                  show_letter_boundry = false)
    # Character index position in sprite font
    # NOTE: In case a codepoint is not available in the font, index returned points to '?'
    index = GetGlyphIndex(font, codepoint)
    scale = font_size / font.baseSize.to_f

    # Character destination rectangle on screen
    # NOTE: We consider charsPadding on drawing
    glyph_info = GlyphInfo.new(font.glyphs + index * GlyphInfo.size)
    pos = Vector3.create(position.x, position.y, position.z)
    pos.x += (glyph_info.offsetX - font.glyphPadding) * scale
    pos.z += (glyph_info.offsetY - font.glyphPadding) * scale

    # Character source rectangle from font texture atlas
    # NOTE: We consider chars padding when drawing, it could be required for outline/glow shader effects
    font_rec = Rectangle.new(font.recs + index * Rectangle.size)
    src_rec = Rectangle.create(font_rec.x - font.glyphPadding, font_rec.y - font.glyphPadding.to_f,
                               font_rec.width + 2.0 * font.glyphPadding,
                               font_rec.height + 2.0 * font.glyphPadding)

    width = (font_rec.width + 2.0 * font.glyphPadding) * scale
    height = (font_rec.height + 2.0 * font.glyphPadding) * scale

    return unless font.texture.id > 0

    x = 0.0
    y = 0.0
    z = 0.0

    # normalized texture coordinates of the glyph inside the font texture (0.0f -> 1.0f)
    tx = src_rec.x / font.texture.width
    ty = src_rec.y / font.texture.height
    tw = (src_rec.x + src_rec.width) / font.texture.width
    th = (src_rec.y + src_rec.height) / font.texture.height

    if show_letter_boundry
      DrawCubeWiresV(Vector3.create(pos.x + width / 2, pos.y, pos.z + height / 2),
                     Vector3.create(width, LETTER_BOUNDRY_SIZE, height), LETTER_BOUNDRY_COLOR)
    end

    rlCheckRenderBatchLimit(4 + (backface ? 4 : 0))
    rlSetTexture(font.texture.id)

    rlPushMatrix()
      rlTranslatef(pos.x, pos.y, pos.z)
      rlBegin(RL_QUADS)
        rlColor4ub(tint.r, tint.g, tint.b, tint.a)

        # Front Face (normal pointing up)
        rlNormal3f(0.0, 1.0, 0.0)
        rlTexCoord2f(tx, ty); rlVertex3f(x,         y, z)
        rlTexCoord2f(tx, th); rlVertex3f(x,         y, z + height)
        rlTexCoord2f(tw, th); rlVertex3f(x + width, y, z + height)
        rlTexCoord2f(tw, ty); rlVertex3f(x + width, y, z)

        if backface
          # Back Face (normal pointing down)
          rlNormal3f(0.0, -1.0, 0.0)
          rlTexCoord2f(tx, ty); rlVertex3f(x,         y, z)
          rlTexCoord2f(tw, ty); rlVertex3f(x + width, y, z)
          rlTexCoord2f(tw, th); rlVertex3f(x + width, y, z + height)
          rlTexCoord2f(tx, th); rlVertex3f(x,         y, z + height)
        end
      rlEnd()
    rlPopMatrix()

    rlSetTexture(0)
  end

  # Draw a 2D text in 3D space
  def self.draw_text_3d(font, text, position, font_size, font_spacing, line_spacing, backface,
                        tint, show_letter_boundry = false)
    text_offset_y = 0.0 # Offset between lines (on line break '\n')
    text_offset_x = 0.0 # Offset X to next character to draw

    scale = font_size / font.baseSize.to_f

    text.each_codepoint do |codepoint|
      index = GetGlyphIndex(font, codepoint)

      if codepoint == 10 # '\n'
        # NOTE: Fixed line spacing of 1.5 line-height
        text_offset_y += font_size + line_spacing
        text_offset_x = 0.0
      else
        unless codepoint == 32 || codepoint == 9 # ' ' or '\t'
          draw_text_codepoint_3d(font, codepoint,
                                 Vector3.create(position.x + text_offset_x, position.y,
                                                position.z + text_offset_y),
                                 font_size, backface, tint, show_letter_boundry)
        end

        glyph_info = GlyphInfo.new(font.glyphs + index * GlyphInfo.size)
        if glyph_info.advanceX == 0
          font_rec = Rectangle.new(font.recs + index * Rectangle.size)
          text_offset_x += font_rec.width * scale + font_spacing
        else
          text_offset_x += glyph_info.advanceX * scale + font_spacing
        end
      end
    end
  end

  # Draw a 2D text in 3D space and wave the parts that start with `~~` and end with `~~`
  # This is a modified version of the original code by @Nighten
  # found here https://github.com/NightenDushi/Raylib_DrawTextStyle
  def self.draw_text_wave_3d(font, text, position, font_size, font_spacing, line_spacing,
                             backface, config, time, tint, show_letter_boundry = false)
    text_offset_y = 0.0 # Offset between lines (on line break '\n')
    text_offset_x = 0.0 # Offset X to next character to draw

    scale = font_size / font.baseSize.to_f

    wave = false
    k = 0
    chars = text.chars
    i = 0
    while i < chars.length
      codepoint = chars[i].ord
      index = GetGlyphIndex(font, codepoint)

      if codepoint == 10 # '\n'
        # NOTE: Fixed line spacing of 1.5 line-height
        text_offset_y += font_size + line_spacing
        text_offset_x = 0.0
        k = 0
      elsif codepoint == 126 # '~'
        if chars[i + 1] == '~'
          wave = !wave
          i += 1
        end
      else
        unless codepoint == 32 || codepoint == 9 # ' ' or '\t'
          pos = Vector3.create(position.x, position.y, position.z)
          if wave # Apply the wave effect
            pos.x += Math.sin(time * config.wave_speed.x - k * config.wave_offset.x) * config.wave_range.x
            pos.y += Math.sin(time * config.wave_speed.y - k * config.wave_offset.y) * config.wave_range.y
            pos.z += Math.sin(time * config.wave_speed.z - k * config.wave_offset.z) * config.wave_range.z
          end

          draw_text_codepoint_3d(font, codepoint,
                                 Vector3.create(pos.x + text_offset_x, pos.y,
                                                pos.z + text_offset_y),
                                 font_size, backface, tint, show_letter_boundry)
        end

        glyph_info = GlyphInfo.new(font.glyphs + index * GlyphInfo.size)
        if glyph_info.advanceX == 0
          font_rec = Rectangle.new(font.recs + index * Rectangle.size)
          text_offset_x += font_rec.width * scale + font_spacing
        else
          text_offset_x += glyph_info.advanceX * scale + font_spacing
        end
      end

      i += 1
      k += 1
    end
  end

  # Measure a text in 3D ignoring the `~~` chars
  def self.measure_text_wave_3d(font, text, font_size, font_spacing, line_spacing)
    temp_len = 0             # Used to count longer text line num chars
    len_counter = 0
    temp_text_width = 0.0    # Used to count longer text line width
    text_width = 0.0

    scale = font_size / font.baseSize.to_f
    text_height = scale

    chars = text.chars
    i = 0
    while i < chars.length
      codepoint = chars[i].ord
      index = GetGlyphIndex(font, codepoint)

      if codepoint != 10 # '\n'
        if codepoint == 126 && chars[i + 1] == '~' # '~' '~'
          i += 1
        else
          len_counter += 1
          glyph_info = GlyphInfo.new(font.glyphs + index * GlyphInfo.size)
          if glyph_info.advanceX != 0
            text_width += glyph_info.advanceX * scale
          else
            font_rec = Rectangle.new(font.recs + index * Rectangle.size)
            text_width += (font_rec.width + glyph_info.offsetX) * scale
          end
        end
      else
        temp_text_width = text_width if temp_text_width < text_width
        len_counter = 0
        text_width = 0.0
        text_height += font_size + line_spacing
      end

      temp_len = len_counter if temp_len < len_counter
      i += 1
    end

    temp_text_width = text_width if temp_text_width < text_width

    Vector3.create(temp_text_width + (temp_len - 1) * font_spacing, 0.25, text_height)
  end

  # Generates a nice color with a random hue
  def self.generate_random_color(s, v)
    phi = 0.618033988749895 # Golden ratio conjugate
    h = GetRandomValue(0, 360)
    h = (h + h * phi) % 360.0
    ColorFromHSV(h, s, v)
  end
end
