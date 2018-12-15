# frozen_string_literal: true
require_relative 'recipes'

class Solver
  def initialize(n)
    @recipes = Recipes.new

    debug
    until @recipes.size >= n + 10
      @recipes.append new_recipes
      @recipes.elves_scores.each.with_index do |score, elf|
        @recipes.move(elf, score + 1)
      end
      debug
    end
    @scores
    puts @recipes.to_a.drop(n).take(10).join
  end

  def new_recipes
    @recipes.elves_scores.sum.digits.reverse
  end

  def debug
    # puts @recipes.debug
    puts @recipes.size if @recipes.size % 1000 == 0
  end
end

Solver.new(360781)
