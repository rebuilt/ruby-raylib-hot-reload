class QuestionThreeUpMoonBlock < QuestionItemBlock
  def createItem(mario)
    ThreeUpMoon.new(Vector2.create(@pos.x, @pos.y), Vector2.create(32, 32), Vector2.create(300, 0), YELLOW)
  end
end
