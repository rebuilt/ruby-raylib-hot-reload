class QuestionFireFlowerBlock < QuestionItemBlock
  def createItem(mario)
    FireFlower.new(Vector2.create(@pos.x, @pos.y), Vector2.create(32, 32), ORANGE)
  end
end
