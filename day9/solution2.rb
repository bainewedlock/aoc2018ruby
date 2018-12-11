require_relative 'linked_list'

class Solver
  def initialize(players, marbles)
    @list = LinkedList.new
    @list.insert 0
    @player = 0
    @players = Array.new(players, 0)

    play marbles

    puts "solution for #{players}/#{marbles}: #{@players.max}"
  end

  def play(marbles)
    (1..marbles).each do |value|
      if (value % 23).zero?
        score value
        @list.rotate_backward 7
        score @list.remove
      else
        @list.rotate_forward 2
        @list.insert value
      end

      # debug
      puts "marble ##{value}" if (value % 1_000_000).zero?
      next_player
    end
  end

  def next_player
    @player = (@player + 1) % @players.size
  end

  def score(value)
    @players[@player] += value
  end

  def debug
    print "[#{@player + 1}]  "
    @list.debug
    print "\n"
  end
end

Solver.new(9, 25)
Solver.new(10, 1618)
Solver.new(13, 7999)
Solver.new(17, 1104)
Solver.new(21, 6111)
Solver.new(30, 5807)
Solver.new(423, 71_944)
Solver.new(423, 7_194_400)

