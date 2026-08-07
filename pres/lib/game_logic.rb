# raylib [text] example - 3d drawing
#
# Translated from threed.c (examples/text/text_draw_3d.c) by Vlad Adrian
# (@demizdor), reviewed by Ramon Santamaria (@raysan5).
#
# Draws a 2D text in 3D space using the default font, with an optional wavy
# effect on the parts wrapped in `~~...~~`. The text can be typed live, its
# size/spacing/layers adjusted with the keyboard and the font swapped by
# dragging a font file onto the window.

require_relative "threed"

module GameLogic
  def self.init(state)
    MAX_BUILDINGS = 100


    state.player = Rectangle.create(400, 280, 40, 40)
    state.buildings = Array.new(MAX_state.buildings) { Rectangle.create(0, 0, 0, 0) }
    state.buildColors = Array.new(MAX_state.buildings)

    spacing = 0

    MAX_state.buildings.times do |i|
      state.buildings[i].width = GetRandomValue(50, 200).to_f
      state.buildings[i].height = GetRandomValue(100, 800).to_f
      state.buildings[i].y = screenHeight - 130.0 - state.buildings[i].height
      state.buildings[i].x = -6000.0 + spacing

      spacing += state.buildings[i].width.to_i

      state.buildColors[i] = Color.from_u8(GetRandomValue(200, 240), GetRandomValue(200, 240), GetRandomValue(200, 250), 255)
    end

    camera = Camera2D.new
               .with_target(state.player.x + 20.0, state.player.y + 20.0)
               .with_offset(screenWidth / 2.0, screenHeight / 2.0)
               .with_rotation(0.0)
               .with_zoom(1.0)

    SetTargetFPS(60)
  end

  def self.update(state)
    # Player movement
    if IsKeyDown(KEY_RIGHT)
      state.player.x += 2
    elsif IsKeyDown(KEY_LEFT)
      state.player.x -= 2
    end

    # Camera target follows player
    camera.target.set(state.player.x + 20, state.player.y + 20)

    # Camera rotation controls
    if IsKeyDown(KEY_A)
      camera.rotation -= 1
    elsif IsKeyDown(KEY_S)
      camera.rotation += 1
    end

    # Limit camera rotation to 80 degrees (-40 to 40)
    camera.rotation = camera.rotation.clamp(-40, 40)

    # Camera zoom controls
    camera.zoom += GetMouseWheelMove() * 0.05
    camera.zoom = camera.zoom.clamp(0.1, 3.0)

    # Camera reset (zoom and rotation)
    camera.zoom, camera.rotation = 1.0, 0.0 if IsKeyPressed(KEY_R)
  end

  def self.draw(state)

    BeginDrawing()
      ClearBackground(RAYWHITE)

      BeginMode2D(camera)
        DrawRectangle(-6000, 320, 13000, 8000, DARKGRAY)

        MAX_state.buildings.times { |i| DrawRectangleRec(state.buildings[i], state.buildColors[i]) }

        DrawRectangleRec(state.player, RED)

        DrawLine(camera.target.x.to_i, -screenHeight*10, camera.target.x.to_i, screenHeight*10, GREEN)
        DrawLine(-screenWidth*10, camera.target.y.to_i, screenWidth*10, camera.target.y.to_i, GREEN)
      EndMode2D()

      DrawText("SCREEN AREA", 640, 10, 20, RED)

      DrawRectangle(0, 0, screenWidth, 5, RED)
      DrawRectangle(0, 5, 5, screenHeight - 10, RED)
      DrawRectangle(screenWidth - 5, 5, 5, screenHeight - 10, RED)
      DrawRectangle(0, screenHeight - 5, screenWidth, 5, RED)

      DrawRectangle(10, 10, 250, 113, Fade(SKYBLUE, 0.5))
      DrawRectangleLines(10, 10, 250, 113, BLUE)

      DrawText("Free 2d camera controls:", 20, 20, 10, BLACK)
      DrawText("- Right/Left to move Offset", 40, 40, 10, DARKGRAY)
      DrawText("- Mouse Wheel to Zoom in-out", 40, 60, 10, DARKGRAY)
      DrawText("- A / S to Rotate", 40, 80, 10, DARKGRAY)
      DrawText("- R to reset Zoom and Rotation", 40, 100, 10, DARKGRAY)

    EndDrawing()
  end
end
