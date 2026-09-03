module GameLogic
  def self.init(state)
    Raylib.SetTargetFPS(60)

    state.player.position = Vector2.create(640, 360)
    state.player.velocity = Vector2.create(0, 0)
    state.player.size = Vector2.create(32, 32)
    state.player.sprite = Raylib.LoadTexture("resources/balloon_green1.png")

    state.horizontal_movement.left = -1
    state.horizontal_movement.right = 1
    state.horizontal_movement.none = 0
    state.boxes = []
    100.times do
      state.boxes << {
        position: Vector2.create(rand(0..state[:screen_width]),
                                 rand(0..state[:screen_height])),
        size: Vector2.create(rand(1..10), rand(1..10)),
        color: Color.from_u8(rand(0..255), rand(0..255), rand(0..255), 255),
        dx: rand(-100..100),
        dy: rand(-100..100),
      }
    end
    state.orange = Color.from_u8(226, 199, 121, 255)
  end

  def self.update(state)
    horizontal = if Raylib.IsKeyDown(KEY_A) || Raylib.IsKeyDown(KEY_LEFT) || Raylib.IsGamepadButtonDown(0,
                                                                                                        GAMEPAD_BUTTON_LEFT_FACE_LEFT)
                   state.horizontal_movement.left
                 elsif Raylib.IsKeyDown(KEY_D) || Raylib.IsKeyDown(KEY_RIGHT) || Raylib.IsGamepadButtonDown(0,
                                                                                                            GAMEPAD_BUTTON_LEFT_FACE_RIGHT)
                   state.horizontal_movement.right
                 else
                   state.horizontal_movement.none
                 end

    vertical = if Raylib.IsKeyDown(KEY_W) || Raylib.IsKeyDown(KEY_UP) || Raylib.IsGamepadButtonDown(0,
                                                                                                    GAMEPAD_BUTTON_LEFT_FACE_UP)
                 -1
               elsif Raylib.IsKeyDown(KEY_S) || Raylib.IsKeyDown(KEY_DOWN) || Raylib.IsGamepadButtonDown(0,
                                                                                                         GAMEPAD_BUTTON_LEFT_FACE_DOWN)
                 1
               else
                 0
               end

    state[:player][:velocity].x = if Raylib.IsGamepadButtonDown(0, GAMEPAD_BUTTON_RIGHT_FACE_LEFT)
                                    horizontal * 400
                                  else
                                    horizontal * 200
                                  end
    state[:player][:velocity].y = if Raylib.IsGamepadButtonDown(0, GAMEPAD_BUTTON_RIGHT_FACE_LEFT)
                                    vertical * 400
                                  else
                                    vertical * 200
                                  end

    state.player.position.x += state[:player][:velocity].x * Raylib.GetFrameTime
    state[:player][:position].y += state[:player][:velocity].y * Raylib.GetFrameTime
    if state[:player][:position].y < 0
      state[:player][:position].y = 0
    elsif state[:player][:position].y > state[:screen_height] - state[:player][:size].y
      state[:player][:position].y = state[:screen_height] - state[:player][:size].y
    end
    if state[:player][:position].x < 0
      state[:player][:position].x = Raylib.GetScreenWidth() - state[:player][:size].x
    elsif state[:player][:position].x > Raylib.GetScreenWidth() - state[:player][:size].x
      state[:player][:position].x = 0
    end

    state.boxes.each do |box|
      box[:position].x += box[:dx] * Raylib.GetFrameTime
      box[:position].y += box[:dy] * Raylib.GetFrameTime

      box[:dx] *= -1 if box[:position].x < 0 || box[:position].x > state[:screen_width] - box[:size].x
      box[:dy] *= -1 if box[:position].y < 0 || box[:position].y > state[:screen_height] - box[:size].y
    end
  end

  def self.draw(state)
    Raylib.BeginDrawing
    Raylib.ClearBackground(Color.from_u8(100, 149, 237))

    # state.boxes.each do |box|
    #   Raylib.DrawRectangleV(box[:position], box[:size], box[:color])
    # end

    state.boxes.each do |box|
      x = box[:position].x
      y = box[:position].y
      size_x = box[:size].x

      Raylib.DrawCircleV(box[:position], box[:size].x, box[:color])
      # Raylib.DrawTriangle(box[:position], Vector2.create(box[:position].x - box[:size].x, box[:position].y),
      # Vector2.create(box[:position].x / 2, box[:position].y + box[:size].y), box[:color])
      point1 = Vector2.create(x + size_x, y + size_x / 2)
      point2 = Vector2.create(x - size_x, point1.y)
      point3 = Vector2.create(point2.x + (point1.x - point2.x) / 2, point1.y + size_x * 2.5)
      Raylib.DrawTriangle(point1, point2, point3, state.orange)
    end

    # Raylib.DrawTriangle(Vector2.create(400, 300), Vector2.create(350, 300), Vector2.create(375, 350), RED)

    Raylib.DrawTexture(state.player.sprite, state.player.position.x, state.player.position.y, WHITE)
    # HUD
    Raylib.DrawText("WASD or arrows move, D-pad also works", 10, 10, 20, DARKGRAY)
    Raylib.DrawText("F5 reset", 10, 35, 20, DARKGRAY)
    Raylib.DrawFPS(10, 90)

    Raylib.EndDrawing
  end
end
