
module GameLogic
  def self.init(state)
    state.screen_width = 1280
    state.screen_height = 720
    InitWindow(state.screen_width, state.screen_height, "Yet Another Ruby-raylib bindings")
    SetTargetFPS(60)

    state.ruby_red = Color.from_u8(155, 17, 30, 255)

    # Camera
    state.camera = Camera.new
    state.reset_camera = lambda {
      state.camera.position.set(0.0, 10.0, 10.0)
      state.camera.target.set(0.0, 0.0, 0.0)
      state.camera.up.set(0.0, 1.0, 0.0)
      state.camera.fovy = 45.0
      state.camera.projection = CAMERA_PERSPECTIVE
    }
    state.reset_camera.call
    state.camera_mode = CAMERA_CUSTOM
    state.auto_rotate = false

    # Player (red cube) settings
    state.player_pos = Vector3.create(0.0, 0.0, 0.0)
    state.player_size = Vector3.create(2.0, 2.0, 2.0)
    state.speed = 0.25

    # Obstacle settings
    state.obstacle_cube_pos = Vector3.create(-4.0, 1.0, 0.0)
    state.obstacle_cube_size = Vector3.create(2.0, 2.0, 2.0)
    state.obstacle_sphere_pos = Vector3.create(4.0, 0.0, 0.0)
    state.obstacle_sphere_size = 1.5
  end

  def self.update(state)
    # Reset camera settings
    if IsKeyPressed(KEY_F1)
      state.auto_rotate = !state.auto_rotate
      state.reset_camera.call
      state.camera_mode = state.auto_rotate ? CAMERA_ORBITAL : CAMERA_CUSTOM
    end

    UpdateCamera(state.camera.pointer, state.camera_mode) if state.auto_rotate

    # Calculate move direction
    move = Vector3.create(0, 0, 0)
    move.x += state.speed if IsKeyDown(KEY_RIGHT)
    move.x -= state.speed if IsKeyDown(KEY_LEFT)
    move.z += state.speed if IsKeyDown(KEY_DOWN)
    move.z -= state.speed if IsKeyDown(KEY_UP)

    to_camera = Vector3Normalize(Vector3.create(state.camera.position.x, 0, state.camera.position.z))
    rotate_y = QuaternionFromVector3ToVector3(Vector3.create(0, 0, 1), to_camera)
    move = Vector3RotateByQuaternion(move, rotate_y)

    state.player_pos = Vector3Add(state.player_pos, move)
    state.player_screen_pos = GetWorldToScreen(
      Vector3.create(state.player_pos.x, state.player_pos.y + 2.5, state.player_pos.z), state.camera
    )

    # Check collision status
    state.collision = false

    player_bbox = BoundingBox.new
      .with_min(state.player_pos.x - state.player_size.x / 2, state.player_pos.y - state.player_size.y / 2, state.player_pos.z - state.player_size.z / 2)
      .with_max(state.player_pos.x + state.player_size.x / 2, state.player_pos.y + state.player_size.y / 2, state.player_pos.z + state.player_size.z / 2)

    obstacle_cube_bbox = BoundingBox.new
      .with_min(state.obstacle_cube_pos.x - state.obstacle_cube_size.x / 2, state.obstacle_cube_pos.y - state.obstacle_cube_size.y / 2, state.obstacle_cube_pos.z - state.obstacle_cube_size.z / 2)
      .with_max(state.obstacle_cube_pos.x + state.obstacle_cube_size.x / 2, state.obstacle_cube_pos.y + state.obstacle_cube_size.y / 2, state.obstacle_cube_pos.z + state.obstacle_cube_size.z / 2)

    # Check collisions player vs obstacle_cube
    state.collision = true if CheckCollisionBoxes(player_bbox, obstacle_cube_bbox)

    # Check collisions player vs obstacle_sphere
    state.collision = true if CheckCollisionBoxSphere(player_bbox, state.obstacle_sphere_pos,
      state.obstacle_sphere_size)
  end

  def self.draw(state)
    ### Rendering phase

    BeginDrawing()

    ClearBackground(RAYWHITE)

    ## 3D scene
    BeginMode3D(state.camera)
    # Red cube
    DrawCube(state.player_pos, 2.0, 2.0, 2.0, state.collision ? Fade(state.ruby_red, 0.25) : state.ruby_red)
    DrawCubeWires(state.player_pos, 2.0, 2.0, 2.0, MAROON)
    # Obstacle cube
    DrawCube(state.obstacle_cube_pos, state.obstacle_cube_size.x, state.obstacle_cube_size.y,
      state.obstacle_cube_size.z, GRAY)
    DrawCubeWires(state.obstacle_cube_pos, state.obstacle_cube_size.x, state.obstacle_cube_size.y,
      state.obstacle_cube_size.z, DARKGRAY)
    # Obstacle sphere
    DrawSphere(state.obstacle_sphere_pos, state.obstacle_sphere_size, GRAY)
    DrawSphereWires(state.obstacle_sphere_pos, state.obstacle_sphere_size, 16, 16, DARKGRAY)
    # Floor
    DrawGrid(10, 1)
    EndMode3D()

    ## HUD
    # Text over the red cube
    DrawText("Player HP: 100 / 100", state.player_screen_pos.x - MeasureText("Player HP: 100/100", 20) / 2,
      state.player_screen_pos.y, 20, BLACK)
    # Help message
    DrawRectangle(10, state.screen_height - 100, 300, 80, Fade(MAROON, 0.25))
    DrawRectangleLines(10, state.screen_height - 100, 300, 80, state.ruby_red)
    DrawText("Arrow keys : move red cube", 20, state.screen_height - 90, 20, BLACK)
    DrawText("F1 : camera rotation", 20, state.screen_height - 70, 20, BLACK)
    DrawText("ESC : exit", 20, state.screen_height - 50, 20, BLACK)
    # FPS
    DrawFPS(state.screen_width - 100, 16)

    EndDrawing()
  end
end
