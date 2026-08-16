class QuestionMushroomBlock < QuestionItemBlock
  def createItem(mario)
    Mushroom.new(Vector2.create(@pos.x, @pos.y), Vector2.create(32, 32), Vector2.create(200, 0), RED)
  end
end
