class QuestionOneUpMushroomBlock < QuestionItemBlock
  def createItem(mario)
    OneUpMushroom.new(Vector2.create(@pos.x, @pos.y), Vector2.create(32, 32), Vector2.create(250, 0), GREEN)
  end
end
