#  
module GameLogic
  def self.update(state)
    state[:counter] +=  1
  end

  def self.draw(state)
    puts "counter=#{state[:counter]}"
  end
end
