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

    state.spin = false        # Spin the camera?
    state.multicolor = false # Multicolor mode

    # Define the camera to look into our 3d world
    state.camera = Camera.new
    state.camera.position = Vector3.create(-10.0, 15.0, -10.0) # Camera position
    state.camera.target = Vector3.create(0.0, 0.0, 0.0)        # Camera looking at point
    state.camera.up = Vector3.create(0.0, 1.0, 0.0)            # Camera up vector (rotation towards target)
    state.camera.fovy = 45.0                                   # Camera field-of-view Y
    state.camera.projection = CAMERA_PERSPECTIVE               # Camera projection type
    state.camera_mode = CAMERA_ORBITAL

    state.cube_position = Vector3.create(0.0, 1.0, 0.0)
    state.cube_size = Vector3.create(2.0, 2.0, 2.0)

    # Use the default font
    state.font = GetFontDefault()
    state.font_size = 0.8
    state.font_spacing = 0.05
    state.line_spacing = -0.1

    # Set the text (using markdown!)
    state.text = "Hello ~~World~~ in 3D!"
    state.tbox = Vector3.create(0, 0, 0)
    state.layers = 1
    state.quads = 0
    state.layer_distance = 0.01

    state.wcfg = Threed::WaveTextConfig.new

    state.time = 0.0

    # Setup a light and dark color
    state.light = MAROON
    state.dark = RED

    # Load the alpha discard shader
    state.alpha_discard = Threed.load_alpha_discard_shader

    # Array filled with multiple random colors (when multicolor mode is set)
    state.multi = Array.new(Threed::TEXT_MAX_LAYERS) { Color.new }

    state.show_letter_boundry = false
    state.show_text_boundry = false

    # DisableCursor() # Limit cursor to relative movement inside the window

    SetTargetFPS(60) # Set our game to run at 60 frames-per-second
  end

  def self.update(state)

    UpdateCamera(state.camera.pointer, state.camera_mode)

    # Handle font files dropped
    if IsFileDropped()
      dropped_files = LoadDroppedFiles()
      path = dropped_files.paths.read_pointer.read_string

      # NOTE: We only support first ttf file dropped
      if IsFileExtension(path, ".ttf")
        UnloadFont(state.font)
        state.font = LoadFontEx(path, state.font_size.to_i, nil, 0)
      elsif IsFileExtension(path, ".fnt")
        UnloadFont(state.font)
        state.font = LoadFont(path)
        state.font_size = state.font.baseSize.to_f
      end

      UnloadDroppedFiles(dropped_files) # Unload filepaths from memory
    end

    # Handle Events
    state.show_letter_boundry = !state.show_letter_boundry if IsKeyPressed(KEY_F1)
    state.show_text_boundry = !state.show_text_boundry if IsKeyPressed(KEY_F2)
    if IsKeyPressed(KEY_F3)
      # Handle camera change
      state.spin = !state.spin
      # we need to reset the camera when changing modes
      state.camera.target = Vector3.create(0.0, 0.0, 0.0) # Camera looking at point
      state.camera.up = Vector3.create(0.0, 1.0, 0.0)     # Camera up vector (rotation towards target)
      state.camera.fovy = 45.0                            # Camera field-of-view Y
      state.camera.projection = CAMERA_PERSPECTIVE        # Camera projection type

      if state.spin
        state.camera.position = Vector3.create(-10.0, 15.0, -10.0) # Camera position
        state.camera_mode = CAMERA_ORBITAL
      else
        state.camera.position = Vector3.create(10.0, 10.0, -10.0) # Camera position
        state.camera_mode = CAMERA_FREE
      end
    end

    # Handle clicking the cube
    if IsMouseButtonPressed(MOUSE_BUTTON_LEFT)
      ray = GetScreenToWorldRay(GetMousePosition(), state.camera)

      # Check collision between ray and box
      collision = GetRayCollisionBox(ray, BoundingBox.new
        .with_min(state.cube_position.x - state.cube_size.x / 2,
                  state.cube_position.y - state.cube_size.y / 2,
                  state.cube_position.z - state.cube_size.z / 2)
        .with_max(state.cube_position.x + state.cube_size.x / 2,
                  state.cube_position.y + state.cube_size.y / 2,
                  state.cube_position.z + state.cube_size.z / 2))

      if collision.hit
        # Generate new random colors
        state.light = Threed.generate_random_color(0.5, 0.78)
        state.dark = Threed.generate_random_color(0.4, 0.58)
      end
    end

    # Handle text layers changes
    if IsKeyPressed(KEY_HOME)
      state.layers -= 1 if state.layers > 1
    elsif IsKeyPressed(KEY_END)
      state.layers += 1 if state.layers < Threed::TEXT_MAX_LAYERS
    end

    # Handle text changes
    if IsKeyPressed(KEY_LEFT)
      state.font_size -= 0.5
    elsif IsKeyPressed(KEY_RIGHT)
      state.font_size += 0.5
    elsif IsKeyPressed(KEY_UP)
      state.font_spacing -= 0.1
    elsif IsKeyPressed(KEY_DOWN)
      state.font_spacing += 0.1
    elsif IsKeyPressed(KEY_PAGE_UP)
      state.line_spacing -= 0.1
    elsif IsKeyPressed(KEY_PAGE_DOWN)
      state.line_spacing += 0.1
    elsif IsKeyDown(KEY_INSERT)
      state.layer_distance -= 0.001
    elsif IsKeyDown(KEY_DELETE)
      state.layer_distance += 0.001
    elsif IsKeyPressed(KEY_TAB)
      state.multicolor = !state.multicolor # Enable /disable multicolor mode

      if state.multicolor
        # Fill color array with random colors
        Threed::TEXT_MAX_LAYERS.times do |i|
          state.multi[i] = Threed.generate_random_color(0.5, 0.8)
          state.multi[i].a = GetRandomValue(0, 255)
        end
      end
    end

    # Handle text input
    ch = GetCharPressed()
    if IsKeyPressed(KEY_BACKSPACE)
      # Remove last char
      state.text.chop!
    elsif IsKeyPressed(KEY_ENTER)
      # handle newline
      state.text << "\n"
    elsif ch != 0
      # append only printable chars
      state.text << ch
    end

    # Measure 3D text so we can center it
    state.tbox = Threed.measure_text_wave_3d(state.font, state.text, state.font_size,
                                             state.font_spacing, state.line_spacing)

    state.quads = 0              # Reset quad counter
    state.time += GetFrameTime() # Update timer needed by draw_text_wave_3d()
  end

  def self.draw(state)
    BeginDrawing()

    ClearBackground(RAYWHITE)

    BeginMode3D(state.camera)
      DrawCubeV(state.cube_position, state.cube_size, state.dark)
      DrawCubeWires(state.cube_position, 2.1, 2.1, 2.1, state.light)

      DrawGrid(10, 2.0)

      # Use a shader to handle the depth buffer issue with transparent textures
      # NOTE: more info at https://bedroomcoders.co.uk/posts/198
      BeginShaderMode(state.alpha_discard)

        # Draw the 3D text above the red cube
        rlPushMatrix()
          rlRotatef(90.0, 1.0, 0.0, 0.0)
          rlRotatef(90.0, 0.0, 0.0, -1.0)

          state.layers.times do |i|
            clr = state.multicolor ? state.multi[i] : state.light
            Threed.draw_text_wave_3d(state.font, state.text,
                                     Vector3.create(-state.tbox.x / 2.0, state.layer_distance * i, -4.5),
                                     state.font_size, state.font_spacing, state.line_spacing,
                                     true, state.wcfg, state.time, clr, state.show_letter_boundry)
          end

          # Draw the text boundry if set
          if state.show_text_boundry
            DrawCubeWiresV(Vector3.create(0.0, 0.0, -4.5 + state.tbox.z / 2), state.tbox, state.dark)
          end
        rlPopMatrix()

        # Don't draw the letter boundries for the 3D text below
        slb = state.show_letter_boundry
        state.show_letter_boundry = false

        # Draw 3D options (use default font)
        rlPushMatrix()
          rlRotatef(180.0, 0.0, 1.0, 0.0)

          opt = format("< SIZE: %2.1f >", state.font_size)
          state.quads += opt.bytesize
          m = MeasureTextEx(GetFontDefault(), opt, 0.8, 0.1)
          pos = Vector3.create(-m.x / 2.0, 0.01, 2.0)
          Threed.draw_text_3d(GetFontDefault(), opt, pos, 0.8, 0.1, 0.0, false, BLUE,
                              state.show_letter_boundry)
          pos.z += 0.5 + m.y

          opt = format("< SPACING: %2.1f >", state.font_spacing)
          state.quads += opt.bytesize
          m = MeasureTextEx(GetFontDefault(), opt, 0.8, 0.1)
          pos.x = -m.x / 2.0
          Threed.draw_text_3d(GetFontDefault(), opt, pos, 0.8, 0.1, 0.0, false, BLUE,
                              state.show_letter_boundry)
          pos.z += 0.5 + m.y

          opt = format("< LINE: %2.1f >", state.line_spacing)
          state.quads += opt.bytesize
          m = MeasureTextEx(GetFontDefault(), opt, 0.8, 0.1)
          pos.x = -m.x / 2.0
          Threed.draw_text_3d(GetFontDefault(), opt, pos, 0.8, 0.1, 0.0, false, BLUE,
                              state.show_letter_boundry)
          pos.z += 0.5 + m.y

          opt = format("< LBOX: %3s >", slb ? "ON" : "OFF")
          state.quads += opt.bytesize
          m = MeasureTextEx(GetFontDefault(), opt, 0.8, 0.1)
          pos.x = -m.x / 2.0
          Threed.draw_text_3d(GetFontDefault(), opt, pos, 0.8, 0.1, 0.0, false, RED,
                              state.show_letter_boundry)
          pos.z += 0.5 + m.y

          opt = format("< TBOX: %3s >", state.show_text_boundry ? "ON" : "OFF")
          state.quads += opt.bytesize
          m = MeasureTextEx(GetFontDefault(), opt, 0.8, 0.1)
          pos.x = -m.x / 2.0
          Threed.draw_text_3d(GetFontDefault(), opt, pos, 0.8, 0.1, 0.0, false, RED,
                              state.show_letter_boundry)
          pos.z += 0.5 + m.y

          opt = format("< LAYER DISTANCE: %.3f >", state.layer_distance)
          state.quads += opt.bytesize
          m = MeasureTextEx(GetFontDefault(), opt, 0.8, 0.1)
          pos.x = -m.x / 2.0
          Threed.draw_text_3d(GetFontDefault(), opt, pos, 0.8, 0.1, 0.0, false, DARKPURPLE,
                              state.show_letter_boundry)
        rlPopMatrix()

        # Draw 3D info text (use default font)
        opt = "All the text displayed here is in 3D"
        state.quads += 36
        m = MeasureTextEx(GetFontDefault(), opt, 1.0, 0.05)
        pos = Vector3.create(-m.x / 2.0, 0.01, 2.0)
        Threed.draw_text_3d(GetFontDefault(), opt, pos, 1.0, 0.05, 0.0, false, DARKBLUE,
                            state.show_letter_boundry)
        pos.z += 1.5 + m.y

        opt = "press [Left]/[Right] to change the font size"
        state.quads += 44
        m = MeasureTextEx(GetFontDefault(), opt, 0.6, 0.05)
        pos.x = -m.x / 2.0
        Threed.draw_text_3d(GetFontDefault(), opt, pos, 0.6, 0.05, 0.0, false, DARKBLUE,
                            state.show_letter_boundry)
        pos.z += 0.5 + m.y

        opt = "press [Up]/[Down] to change the font spacing"
        state.quads += 44
        m = MeasureTextEx(GetFontDefault(), opt, 0.6, 0.05)
        pos.x = -m.x / 2.0
        Threed.draw_text_3d(GetFontDefault(), opt, pos, 0.6, 0.05, 0.0, false, DARKBLUE,
                            state.show_letter_boundry)
        pos.z += 0.5 + m.y

        opt = "press [PgUp]/[PgDown] to change the line spacing"
        state.quads += 48
        m = MeasureTextEx(GetFontDefault(), opt, 0.6, 0.05)
        pos.x = -m.x / 2.0
        Threed.draw_text_3d(GetFontDefault(), opt, pos, 0.6, 0.05, 0.0, false, DARKBLUE,
                            state.show_letter_boundry)
        pos.z += 0.5 + m.y

        opt = "press [F1] to toggle the letter boundry"
        state.quads += 39
        m = MeasureTextEx(GetFontDefault(), opt, 0.6, 0.05)
        pos.x = -m.x / 2.0
        Threed.draw_text_3d(GetFontDefault(), opt, pos, 0.6, 0.05, 0.0, false, DARKBLUE,
                            state.show_letter_boundry)
        pos.z += 0.5 + m.y

        opt = "press [F2] to toggle the text boundry"
        state.quads += 37
        m = MeasureTextEx(GetFontDefault(), opt, 0.6, 0.05)
        pos.x = -m.x / 2.0
        Threed.draw_text_3d(GetFontDefault(), opt, pos, 0.6, 0.05, 0.0, false, DARKBLUE,
                            state.show_letter_boundry)

        state.show_letter_boundry = slb
      EndShaderMode()
    EndMode3D()

    # Draw 2D info text & stats
    DrawText("Drag & drop a font file to change the font!\nType something, see what happens!\n\nPress [F3] to toggle the camera",
             10, 35, 10, BLACK)

    state.quads += state.text.bytesize * 2 * state.layers
    tmp = format("%2i layer(s) | %s camera | %4i quads (%4i verts)", state.layers,
                 state.spin ? "ORBITAL" : "FREE", state.quads, state.quads * 4)
    width = MeasureText(tmp, 10)
    DrawText(tmp, state.screen_width - 20 - width, 10, 10, DARKGREEN)

    tmp = "[Home]/[End] to add/remove 3D text layers"
    width = MeasureText(tmp, 10)
    DrawText(tmp, state.screen_width - 20 - width, 25, 10, DARKGRAY)

    tmp = "[Insert]/[Delete] to increase/decrease distance between layers"
    width = MeasureText(tmp, 10)
    DrawText(tmp, state.screen_width - 20 - width, 40, 10, DARKGRAY)

    tmp = "click the [CUBE] for a random color"
    width = MeasureText(tmp, 10)
    DrawText(tmp, state.screen_width - 20 - width, 55, 10, DARKGRAY)

    tmp = "[Tab] to toggle multicolor mode"
    width = MeasureText(tmp, 10)
    DrawText(tmp, state.screen_width - 20 - width, 70, 10, DARKGRAY)

    DrawFPS(10, 10)

    EndDrawing()
  end
end
