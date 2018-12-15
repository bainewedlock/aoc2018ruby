# frozen_string_literal: true
require_relative 'recipes'

class Solver
  def initialize(cheat)
    @recipes = Recipes.new
    @cheat = cheat

    debug
    loop do
      @recipes.append new_recipes
      @cheat.press_keys(new_recipes) do
        puts @recipes.size - @cheat.size
        return
      end
      @recipes.elves_scores.each.with_index do |score, elf|
        @recipes.move(elf, score + 1)
      end
      debug
    end
  end

  def new_recipes
    @recipes.elves_scores.sum.digits.reverse
  end

  def debug
    # puts @recipes.debug
    puts @recipes.size if @recipes.size % 1000 == 0
  end
end

class CheatCode
  def initialize(text)
    @sequence = text.chars
    @recorded = []
  end

  def press_keys(numbers)
    numbers.each do |number|
      press_key(number) do
        yield
      end
    end
  end

  def press_key(number)
    @recorded = @recorded.last(@sequence.size-1)
    @recorded.push number.to_s
    if @recorded == @sequence
      yield
    end
  end

  def size
    @sequence.size
  end
end

Solver.new(CheatCode.new('51589'))
Solver.new(CheatCode.new('01245'))
Solver.new(CheatCode.new('92510'))
Solver.new(CheatCode.new('59414'))
Solver.new(CheatCode.new('360781'))

