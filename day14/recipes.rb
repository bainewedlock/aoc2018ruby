

class Recipes
  def initialize
    @scores = [3, 7]
    @elves = [0, 1]
  end

  def size
    @scores.size
  end

  def debug
    @scores.map.with_index do |score, index|
      case index
      when @elves[0]
        "(#{score})"
      when @elves[1]
        "[#{score}]"
      else
        " #{score} "
      end
    end.join
  end

  def elves_scores
    @elves.map do |elf|
      @scores[elf]
    end
  end

  def append(scores)
    @scores += scores
  end

  def move(elf, distance)
    @elves[elf] += distance
    @elves[elf] %= @scores.size
  end

  def to_a
    @scores
  end
end



