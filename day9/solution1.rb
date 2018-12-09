class Solver
  def initialize(players, marbles)
    @circle = [0]
    @current_marble = 0
    @player = 0
    @players = Array.new(players, 0)

    play marbles

    puts "solution for #{players}/#{marbles}: #{@players.max}"
  end

  def play(marbles)
    (1..marbles).each do |value|
      if (value % 23).zero?
        score value
        remove cycle(-7)
      else
        insert value, cycle(1) + 1
      end
      # puts value if (value % 10_000).zero?
      next_player
    end
  end

  def next_player
    @player = (@player + 1) % @players.size
  end

  def score(value)
    @players[@player] += value
  end

  def remove(at)
    score @circle[at]
    @circle.delete_at(at)
    @current_marble = at
  end

  def insert(value, at)
    @circle.insert(at, value)
    @current_marble = at
  end

  def debug
    print "[#{@player + 1}]  "
    @circle.each.with_index do |value, index|
      if index == @current_marble
        print "(#{value})"
      else
        print value
      end
      print ' '
    end
    print "\n"
  end

  def cycle(offset)
    (@current_marble + offset) % @circle.size
  end
end

Solver.new(9, 25)
Solver.new(10, 1618)
Solver.new(13, 7999)
Solver.new(17, 1104)
Solver.new(21, 6111)
Solver.new(30, 5807)
Solver.new(423, 71_944)
# Solver.new(423, 7_194_400)

