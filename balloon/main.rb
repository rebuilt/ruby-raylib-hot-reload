# Yet another raylib wrapper for Ruby
#
# * https://github.com/vaiorabbit/raylib-bindings
#
# Demonstrates several key features including:
# * Core      : window management, camera, etc.
# * Gameplay  : fetching player input, collision handling, etc.
# * Rendering : drawing shapes, texts, etc.
#
# To get more information, see:
# * https://www.raylib.com/cheatsheet/cheatsheet.html for API reference
# * https://github.com/vaiorabbit/raylib-bindings/tree/main/examples for more actual codes written in Ruby

require "raylib"
require "listen"
require "debug"
require "ostruct"

require_relative "lib/game_logic"
require_relative "lib/hashlike"

shared_lib_path = Gem::Specification.find_by_name("raylib-bindings").full_gem_path + "/lib/"

case RUBY_PLATFORM
when /mswin|msys|mingw|cygwin/
  Raylib.load_lib(shared_lib_path + "libraylib.dll", raygui_libpath: shared_lib_path + "raygui.dll",
    physac_libpath: shared_lib_path + "physac.dll")
when /darwin/
  arch = RUBY_PLATFORM.split("-")[0]
  Raylib.load_lib(shared_lib_path + "libraylib.#{arch}.dylib",
    raygui_libpath: shared_lib_path + "raygui.#{arch}.dylib", physac_libpath: shared_lib_path + "physac.#{arch}.dylib")
when /linux/
  arch = RUBY_PLATFORM.split("-")[0]
  Raylib.load_lib(shared_lib_path + "libraylib.#{arch}.so", raygui_libpath: shared_lib_path + "raygui.#{arch}.so",
    physac_libpath: shared_lib_path + "physac.#{arch}.so")
else
  raise "Unknown OS: #{RUBY_PLATFORM}"
end

include Raylib

listener = Listen.to("lib") do |modified, added, removed|
  puts(modified: modified, added: added, removed: removed)

  modified.concat(added).each do |file|
    load(file) unless file.nil?
  end
end

listener.start

state = Hashlike.new
state.screen_width = 1280
state.screen_height = 720
InitWindow(state[:screen_width], state[:screen_height], "raylib [text] example - 2d camera")
GameLogic.init(state)
EnableCursor()

until WindowShouldClose()

  GameLogic.init(state) if IsKeyDown(KEY_F5)

  binding.break if IsKeyPressed(KEY_GRAVE)

  GameLogic.update(state)
  GameLogic.draw(state)

end

CloseWindow()
