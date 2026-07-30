require "listen"

require_relative "lib/game_logic"

# Define a listener to watch for changes in the 'lib' directory
listener = Listen.to('lib') do |modified, added, removed|
  puts(modified: modified, added: added, removed: removed)

  modified.concat(added).each do |file|
    load(file) unless file.nil?
  end

end

listener.start
state = { counter: 0 }

# Start the game loop
while true
  GameLogic.update(state)
  GameLogic.draw(state)
  sleep(1)
end


