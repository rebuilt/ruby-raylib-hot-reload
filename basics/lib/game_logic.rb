#  
module GameLogic
  def self.update(state)
    # Example: just increment a counter
    
    increment = Constants::INCREMENT if defined?(Constants::INCREMENT)
    increment ||= 1
    state[:counter] +=  increment
  end

  def self.draw(state)
    puts "counter=#{state[:counter]}"
  end
end
