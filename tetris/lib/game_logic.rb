# Tetris - translated from the raylib classic game (tetris.c)
# Original: Copyright (c) 2015 Ramon Santamaria (@raysan5)

module GameLogic
  {
    SQUARE_SIZE: 20,

    GRID_HORIZONTAL_SIZE: 12,
    GRID_VERTICAL_SIZE: 20,

    LATERAL_SPEED: 10,
    TURNING_SPEED: 12,
    FAST_FALL_AWAIT_COUNTER: 30,

    FADING_TIME: 33,

    EMPTY: 0,
    MOVING: 1,
    FULL: 2,
    BLOCK: 3,
    FADING: 4
  }.each do |name, value|
    const_set(name, value) unless const_defined?(name)
  end

  def self.init(state)
    state.level = 1
    state.lines = 0

    state.fading_color = GRAY

    state.piece_position_x = 0
    state.piece_position_y = 0

    state.pause = false
    state.game_over = false

    state.begin_play = true
    state.piece_active = false
    state.detection = false
    state.line_to_delete = false

    state.gravity_movement_counter = 0
    state.lateral_movement_counter = 0
    state.turn_movement_counter = 0
    state.fast_fall_movement_counter = 0

    state.fade_line_counter = 0
    state.gravity_speed = 30

    state.grid = Array.new(GRID_HORIZONTAL_SIZE) { Array.new(GRID_VERTICAL_SIZE, EMPTY) }

    GRID_HORIZONTAL_SIZE.times do |i|
      GRID_VERTICAL_SIZE.times do |j|
        if (j == GRID_VERTICAL_SIZE - 1) || (i == 0) || (i == GRID_HORIZONTAL_SIZE - 1)
          state.grid[i][j] = BLOCK
        else
          state.grid[i][j] = EMPTY
        end
      end
    end

    state.piece = Array.new(4) { Array.new(4, EMPTY) }
    state.incoming_piece = Array.new(4) { Array.new(4, EMPTY) }

    SetTargetFPS(60)
  end

  def self.update(state)
    unless state.game_over
      state.pause = !state.pause if IsKeyPressed(KEY_P)

      unless state.pause
        unless state.line_to_delete
          unless state.piece_active
            check_completion(state)
            state.piece_active = create_piece(state)
            state.fast_fall_movement_counter = 0
          else
            state.fast_fall_movement_counter += 1
            state.gravity_movement_counter += 1
            state.lateral_movement_counter += 1
            state.turn_movement_counter += 1

            state.lateral_movement_counter = LATERAL_SPEED if IsKeyPressed(KEY_LEFT) || IsKeyPressed(KEY_RIGHT)
            state.turn_movement_counter = TURNING_SPEED if IsKeyPressed(KEY_UP)

            if IsKeyDown(KEY_DOWN) && (state.fast_fall_movement_counter >= FAST_FALL_AWAIT_COUNTER)
              state.gravity_movement_counter += state.gravity_speed
            end

            if state.gravity_movement_counter >= state.gravity_speed
              check_detection(state)
              resolve_falling_movement(state)
              state.gravity_movement_counter = 0
            end

            state.lateral_movement_counter = 0 unless resolve_lateral_movement(state)
            state.turn_movement_counter = 0 if resolve_turn_movement(state)
          end

          (0...2).each do |j|
            (1...GRID_HORIZONTAL_SIZE - 1).each do |i|
              state.game_over = true if state.grid[i][j] == FULL
            end
          end
        else
          state.fade_line_counter += 1

          state.fading_color = (state.fade_line_counter % 8) < 4 ? MAROON : GRAY

          if state.fade_line_counter >= FADING_TIME
            deleted_lines = delete_complete_lines(state)
            state.fade_line_counter = 0
            state.line_to_delete = false
            state.lines += deleted_lines
          end
        end
      end
    else
      if IsKeyPressed(KEY_ENTER)
        init(state)
        state.game_over = false
      end
    end
  end

  def self.draw(state)
    BeginDrawing()
    ClearBackground(RAYWHITE)

    unless state.game_over
      offset_x = GetScreenWidth() / 2 - (GRID_HORIZONTAL_SIZE * SQUARE_SIZE / 2) - 50
      offset_y = GetScreenHeight() / 2 - ((GRID_VERTICAL_SIZE - 1) * SQUARE_SIZE / 2) + (SQUARE_SIZE * 2)

      offset_y -= 50

      controller = offset_x

      GRID_VERTICAL_SIZE.times do |j|
        GRID_HORIZONTAL_SIZE.times do |i|
          case state.grid[i][j]
          when EMPTY
            DrawLine(offset_x, offset_y, offset_x + SQUARE_SIZE, offset_y, LIGHTGRAY)
            DrawLine(offset_x, offset_y, offset_x, offset_y + SQUARE_SIZE, LIGHTGRAY)
            DrawLine(offset_x + SQUARE_SIZE, offset_y, offset_x + SQUARE_SIZE, offset_y + SQUARE_SIZE, LIGHTGRAY)
            DrawLine(offset_x, offset_y + SQUARE_SIZE, offset_x + SQUARE_SIZE, offset_y + SQUARE_SIZE, LIGHTGRAY)
          when FULL
            DrawRectangle(offset_x, offset_y, SQUARE_SIZE, SQUARE_SIZE, GRAY)
          when MOVING
            DrawRectangle(offset_x, offset_y, SQUARE_SIZE, SQUARE_SIZE, DARKGRAY)
          when BLOCK
            DrawRectangle(offset_x, offset_y, SQUARE_SIZE, SQUARE_SIZE, LIGHTGRAY)
          when FADING
            DrawRectangle(offset_x, offset_y, SQUARE_SIZE, SQUARE_SIZE, state.fading_color)
          end
          offset_x += SQUARE_SIZE
        end

        offset_x = controller
        offset_y += SQUARE_SIZE
      end

      offset_x = 500
      offset_y = 45

      controller = offset_x

      4.times do |j|
        4.times do |i|
          case state.incoming_piece[i][j]
          when EMPTY
            DrawLine(offset_x, offset_y, offset_x + SQUARE_SIZE, offset_y, LIGHTGRAY)
            DrawLine(offset_x, offset_y, offset_x, offset_y + SQUARE_SIZE, LIGHTGRAY)
            DrawLine(offset_x + SQUARE_SIZE, offset_y, offset_x + SQUARE_SIZE, offset_y + SQUARE_SIZE, LIGHTGRAY)
            DrawLine(offset_x, offset_y + SQUARE_SIZE, offset_x + SQUARE_SIZE, offset_y + SQUARE_SIZE, LIGHTGRAY)
          when MOVING
            DrawRectangle(offset_x, offset_y, SQUARE_SIZE, SQUARE_SIZE, GRAY)
          end
          offset_x += SQUARE_SIZE
        end

        offset_x = controller
        offset_y += SQUARE_SIZE
      end

      DrawText("INCOMING:", offset_x, offset_y - 100, 10, GRAY)
      DrawText(format("LINES:      %04i", state.lines), offset_x, offset_y + 20, 10, GRAY)

      if state.pause
        DrawText("GAME PAUSED", GetScreenWidth() / 2 - MeasureText("GAME PAUSED", 40) / 2, GetScreenHeight() / 2 - 40, 40, GRAY)
      end
    else
      message = "PRESS [ENTER] TO PLAY AGAIN"
      DrawText(message, GetScreenWidth() / 2 - MeasureText(message, 20) / 2, GetScreenHeight() / 2 - 50, 20, GRAY)
    end

    EndDrawing()
  end

  def self.create_piece(state)
    state.piece_position_x = (GRID_HORIZONTAL_SIZE - 4) / 2
    state.piece_position_y = 0

    if state.begin_play
      get_random_piece(state)
      state.begin_play = false
    end

    4.times do |i|
      4.times do |j|
        state.piece[i][j] = state.incoming_piece[i][j]
      end
    end

    get_random_piece(state)

    (state.piece_position_x...state.piece_position_x + 4).each do |i|
      4.times do |j|
        state.grid[i][j] = MOVING if state.piece[i - state.piece_position_x][j] == MOVING
      end
    end

    true
  end

  def self.get_random_piece(state)
    random = GetRandomValue(0, 6)

    4.times do |i|
      4.times do |j|
        state.incoming_piece[i][j] = EMPTY
      end
    end

    case random
    when 0 # Cube
      state.incoming_piece[1][1] = MOVING
      state.incoming_piece[2][1] = MOVING
      state.incoming_piece[1][2] = MOVING
      state.incoming_piece[2][2] = MOVING
    when 1 # L
      state.incoming_piece[1][0] = MOVING
      state.incoming_piece[1][1] = MOVING
      state.incoming_piece[1][2] = MOVING
      state.incoming_piece[2][2] = MOVING
    when 2 # L inversa
      state.incoming_piece[1][2] = MOVING
      state.incoming_piece[2][0] = MOVING
      state.incoming_piece[2][1] = MOVING
      state.incoming_piece[2][2] = MOVING
    when 3 # Recta
      state.incoming_piece[0][1] = MOVING
      state.incoming_piece[1][1] = MOVING
      state.incoming_piece[2][1] = MOVING
      state.incoming_piece[3][1] = MOVING
    when 4 # Creu tallada
      state.incoming_piece[1][0] = MOVING
      state.incoming_piece[1][1] = MOVING
      state.incoming_piece[1][2] = MOVING
      state.incoming_piece[2][1] = MOVING
    when 5 # S
      state.incoming_piece[1][1] = MOVING
      state.incoming_piece[2][1] = MOVING
      state.incoming_piece[2][2] = MOVING
      state.incoming_piece[3][2] = MOVING
    when 6 # S inversa
      state.incoming_piece[1][2] = MOVING
      state.incoming_piece[2][2] = MOVING
      state.incoming_piece[2][1] = MOVING
      state.incoming_piece[3][1] = MOVING
    end
  end

  def self.resolve_falling_movement(state)
    if state.detection
      (GRID_VERTICAL_SIZE - 2).downto(0) do |j|
        (1...GRID_HORIZONTAL_SIZE - 1).each do |i|
          if state.grid[i][j] == MOVING
            state.grid[i][j] = FULL
            state.detection = false
            state.piece_active = false
          end
        end
      end
    else
      (GRID_VERTICAL_SIZE - 2).downto(0) do |j|
        (1...GRID_HORIZONTAL_SIZE - 1).each do |i|
          if state.grid[i][j] == MOVING
            state.grid[i][j + 1] = MOVING
            state.grid[i][j] = EMPTY
          end
        end
      end

      state.piece_position_y += 1
    end
  end

  def self.resolve_lateral_movement(state)
    collision = false

    if IsKeyDown(KEY_LEFT)
      (GRID_VERTICAL_SIZE - 2).downto(0) do |j|
        (1...GRID_HORIZONTAL_SIZE - 1).each do |i|
          if state.grid[i][j] == MOVING
            collision = true if (i - 1 == 0) || (state.grid[i - 1][j] == FULL)
          end
        end
      end

      unless collision
        (GRID_VERTICAL_SIZE - 2).downto(0) do |j|
          (1...GRID_HORIZONTAL_SIZE - 1).each do |i|
            if state.grid[i][j] == MOVING
              state.grid[i - 1][j] = MOVING
              state.grid[i][j] = EMPTY
            end
          end
        end

        state.piece_position_x -= 1
      end
    elsif IsKeyDown(KEY_RIGHT)
      (GRID_VERTICAL_SIZE - 2).downto(0) do |j|
        (1...GRID_HORIZONTAL_SIZE - 1).each do |i|
          if state.grid[i][j] == MOVING
            collision = true if (i + 1 == GRID_HORIZONTAL_SIZE - 1) || (state.grid[i + 1][j] == FULL)
          end
        end
      end

      unless collision
        (GRID_VERTICAL_SIZE - 2).downto(0) do |j|
          (GRID_HORIZONTAL_SIZE - 1).downto(1) do |i|
            if state.grid[i][j] == MOVING
              state.grid[i + 1][j] = MOVING
              state.grid[i][j] = EMPTY
            end
          end
        end

        state.piece_position_x += 1
      end
    end

    collision
  end

  def self.resolve_turn_movement(state)
    if IsKeyDown(KEY_UP)
      px = state.piece_position_x
      py = state.piece_position_y
      g = state.grid
      checker = false

      checker = true if (g[px + 3][py] == MOVING) && (g[px][py] != EMPTY) && (g[px][py] != MOVING)
      checker = true if (g[px + 3][py + 3] == MOVING) && (g[px + 3][py] != EMPTY) && (g[px + 3][py] != MOVING)
      checker = true if (g[px][py + 3] == MOVING) && (g[px + 3][py + 3] != EMPTY) && (g[px + 3][py + 3] != MOVING)
      checker = true if (g[px][py] == MOVING) && (g[px][py + 3] != EMPTY) && (g[px][py + 3] != MOVING)
      checker = true if (g[px + 1][py] == MOVING) && (g[px][py + 2] != EMPTY) && (g[px][py + 2] != MOVING)
      checker = true if (g[px + 3][py + 1] == MOVING) && (g[px + 1][py] != EMPTY) && (g[px + 1][py] != MOVING)
      checker = true if (g[px + 2][py + 3] == MOVING) && (g[px + 3][py + 1] != EMPTY) && (g[px + 3][py + 1] != MOVING)
      checker = true if (g[px][py + 2] == MOVING) && (g[px + 2][py + 3] != EMPTY) && (g[px + 2][py + 3] != MOVING)
      checker = true if (g[px + 2][py] == MOVING) && (g[px][py + 1] != EMPTY) && (g[px][py + 1] != MOVING)
      checker = true if (g[px + 3][py + 2] == MOVING) && (g[px + 2][py] != EMPTY) && (g[px + 2][py] != MOVING)
      checker = true if (g[px + 1][py + 3] == MOVING) && (g[px + 3][py + 2] != EMPTY) && (g[px + 3][py + 2] != MOVING)
      checker = true if (g[px][py + 1] == MOVING) && (g[px + 1][py + 3] != EMPTY) && (g[px + 1][py + 3] != MOVING)
      checker = true if (g[px + 1][py + 1] == MOVING) && (g[px + 1][py + 2] != EMPTY) && (g[px + 1][py + 2] != MOVING)
      checker = true if (g[px + 2][py + 1] == MOVING) && (g[px + 1][py + 1] != EMPTY) && (g[px + 1][py + 1] != MOVING)
      checker = true if (g[px + 2][py + 2] == MOVING) && (g[px + 2][py + 1] != EMPTY) && (g[px + 2][py + 1] != MOVING)
      checker = true if (g[px + 1][py + 2] == MOVING) && (g[px + 2][py + 2] != EMPTY) && (g[px + 2][py + 2] != MOVING)

      unless checker
        aux = state.piece[0][0]
        state.piece[0][0] = state.piece[3][0]
        state.piece[3][0] = state.piece[3][3]
        state.piece[3][3] = state.piece[0][3]
        state.piece[0][3] = aux

        aux = state.piece[1][0]
        state.piece[1][0] = state.piece[3][1]
        state.piece[3][1] = state.piece[2][3]
        state.piece[2][3] = state.piece[0][2]
        state.piece[0][2] = aux

        aux = state.piece[2][0]
        state.piece[2][0] = state.piece[3][2]
        state.piece[3][2] = state.piece[1][3]
        state.piece[1][3] = state.piece[0][1]
        state.piece[0][1] = aux

        aux = state.piece[1][1]
        state.piece[1][1] = state.piece[2][1]
        state.piece[2][1] = state.piece[2][2]
        state.piece[2][2] = state.piece[1][2]
        state.piece[1][2] = aux
      end

      (GRID_VERTICAL_SIZE - 2).downto(0) do |j|
        (1...GRID_HORIZONTAL_SIZE - 1).each do |i|
          state.grid[i][j] = EMPTY if state.grid[i][j] == MOVING
        end
      end

      (state.piece_position_x...state.piece_position_x + 4).each do |i|
        (state.piece_position_y...state.piece_position_y + 4).each do |j|
          if state.piece[i - state.piece_position_x][j - state.piece_position_y] == MOVING
            state.grid[i][j] = MOVING
          end
        end
      end

      true
    else
      false
    end
  end

  def self.check_detection(state)
    (GRID_VERTICAL_SIZE - 2).downto(0) do |j|
      (1...GRID_HORIZONTAL_SIZE - 1).each do |i|
        if (state.grid[i][j] == MOVING) && ((state.grid[i][j + 1] == FULL) || (state.grid[i][j + 1] == BLOCK))
          state.detection = true
        end
      end
    end
  end

  def self.check_completion(state)
    calculator = 0
    is_empty_row_found = false

    (GRID_VERTICAL_SIZE - 2).downto(0) do |j|
      break if is_empty_row_found

      calculator = 0
      (1...GRID_HORIZONTAL_SIZE - 1).each do |i|
        calculator += 1 if state.grid[i][j] == FULL
      end

      if calculator == GRID_HORIZONTAL_SIZE - 2
        state.line_to_delete = true
        calculator = 0

        (1...GRID_HORIZONTAL_SIZE - 1).each do |z|
          state.grid[z][j] = FADING
        end
      elsif calculator == 0
        is_empty_row_found = true
      end
    end
  end

  def self.delete_complete_lines(state)
    deleted_lines = 0

    (GRID_VERTICAL_SIZE - 2).downto(0) do |j|
      while state.grid[1][j] == FADING
        (1...GRID_HORIZONTAL_SIZE - 1).each do |i|
          state.grid[i][j] = EMPTY
        end

        (j - 1).downto(0) do |j2|
          (1...GRID_HORIZONTAL_SIZE - 1).each do |i2|
            if state.grid[i2][j2] == FULL
              state.grid[i2][j2 + 1] = FULL
              state.grid[i2][j2] = EMPTY
            elsif state.grid[i2][j2] == FADING
              state.grid[i2][j2 + 1] = FADING
              state.grid[i2][j2] = EMPTY
            end
          end
        end

        deleted_lines += 1
      end
    end

    deleted_lines
  end
end
