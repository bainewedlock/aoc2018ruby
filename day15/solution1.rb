# frozen_string_literal: true

class Solver
  def calculate_move(start, targets)
    paths = [[[start], []]]
    visited = [start]
    nearest = nil
    candidates = nil
    loop do
      new_paths = []
      paths.each do |pos, steps|
        pos.last.neighbours_with_step.map do |neighbour, step|
          next if visited.include?(neighbour) or !@floors.include?(neighbour)
          new_paths.push [pos + [neighbour], steps + [step]]
          visited.push neighbour
        end
      end
      return if new_paths.empty? # can't reach enemy
      paths = new_paths
      visited += paths.map { |pos, _| pos.last }
      candidates = paths.select { |pos, _| targets.include? pos.last }
      next unless candidates.any?

      nearest = candidates.min_by do |pos, steps|
        pos[-1].reverse
      end
      break
    end

    target_pos = nearest.first.last
    paths = [[[target_pos], []]]
    previously_visited = visited.clone
    visited = [target_pos]
    loop do
      new_paths = []

      paths.each do |pos, steps|
        pos.last.neighbours_with_step.map do |neighbour, step|
          next if visited.include?(neighbour) or !previously_visited.include?(neighbour)
          new_paths.push [pos + [neighbour], steps + [step]]
          visited.push neighbour unless start == neighbour
        end
      end
      if new_paths.empty?
        require 'pry-byebug'; binding.pry
      end
      paths = new_paths
      visited += paths.map { |pos, _| pos.last }
      return_candidates = paths.select { |pos, _| pos.last == start }
      next unless return_candidates.any?

      pos_to_go = return_candidates.map { |pos, _| pos[-2] }.min_by(&:reverse)

      (_, step_to_take) = start.neighbours_with_step.find { |neighbour, step| neighbour == pos_to_go }

      yield step_to_take
      return
    end
  end

  def initialize(lines)
    @floors = []
    @monsters = []
    @maxx = 0
    @maxy = 0
    lines.each.map.with_index do |line, y|
      line.chars.map.with_index do |char, x|
        @floors.push([x, y]) if char == '.'
        @monsters.push(Monster.new([x, y], char)) if 'GE'.include? char
        @maxx = [@maxx, x].max
        @maxy = [@maxy, y].max
      end
    end
    @round = 0
    loop do
      @monsters.specialsort_by_pos!
      for monster in @monsters.clone
        # next if monster.nil? # was killed
        next if monster.hitpoints <= 0 # was killed in this turn
        enemies = enemies_of(monster.char)
        return game_over if enemies.none?

        hittable = enemies.find { |enemy| monster.pos.neighbours.include? enemy.pos }

        unless hittable
          any_enemy_reachable = enemies.any? { |enemy| (enemy.pos.neighbours & @floors).size > 0 }
          next unless any_enemy_reachable # performance

          in_range = enemies.flat_map { |enemy| in_range_of(enemy.pos) }.uniq
          in_range.specialsort!
          calculate_move(monster.pos, in_range) do |step|
            @floors.push monster.pos
            monster.move step
            @floors.delete monster.pos
          end
        end

        hittable = enemies
          .select { |enemy| monster.pos.neighbours.include? enemy.pos }
          .min_by { |enemy| [enemy.hitpoints, enemy.pos.y, enemy.pos.x] }

        if hittable
          hittable.damage(3) do
            @floors.push hittable.pos
            @monsters.delete(hittable)
          end
        end
      end
      @round += 1
      puts "#{@round} rounds..." if @round % 10 == 0
      # puts "after #{@round} rounds"
      # debug
      # exit
      return game_over if @monsters.map(&:char).uniq.size < 2
    end
  end

  def game_over
    # debug
    hitpoints = @monsters.map(&:hitpoints).sum
    puts "Outcome: #{@round} * #{hitpoints} = #{(@round)* hitpoints}"
  end

  def in_range_of(pos)
    pos.neighbours & @floors
  end

  def enemies_of(char)
    @monsters.reject { |monster| monster.char == char }
  end

  def debug
    print "   "
    for x in 0..@maxx
      print "#{(x/10).to_s}"
    end
    puts
    print "   "
    for x in 0..@maxx
      print "#{(x%10).to_s}"
    end
    puts
    for y in 0..@maxy
      print "#{y.to_s.rjust(2)} "
      for x in 0..@maxx
        pos = [x, y]
        char = '#'
        @monsters.at(pos) do |monster|
          char = monster.char
        end
        char = '.' if @floors.include? pos
        print char

      end
      print "   "
      print @monsters.select { |monster| monster.pos.y == y }
        .sort_by { |monster| monster.pos.x }
        .map(&:text).join(", ")
      puts
    end
  end
end

class Array
  def at(pos)
    found = find { |item| item.pos == pos }
    yield found if found && block_given?
    return found
  end

  def specialsort_by_pos!
    sort_by! { |item| [item.pos.y, item.pos.x] }
  end

  def specialsort!
    sort_by! { |item| [item.y, item.x] }
  end

  def y
    self[1]
  end

  def x
    self[0]
  end

  def neighbours
    neighbours_with_step.map(&:first)
  end

  def neighbours_with_step
    %i[right left down up].map do |step|
      [send(step), step]
    end
  end

  def right
    [x + 1, y]
  end

  def left
    [x - 1, y]
  end

  def up
    [x, y - 1]
  end

  def down
    [x, y + 1]
  end
end

class Monster
  attr_reader :pos
  attr_reader :char
  attr_reader :hitpoints
  def initialize(pos, char)
    @pos = pos
    @char = char
    @hitpoints = 200
  end

  def move(direction)
    @pos = @pos.send(direction)
  end

  def damage(amount)
    @hitpoints -= amount
    # puts "#{@char}:#{@hitpoints}" if @pos == [5, 4]
    yield if @hitpoints <= 0
  end

  def text
    "#{@char}(#{@hitpoints})"
  end

  def text2
    "#{char}#{pos.x}:#{pos.y}"
  end
end

Solver.new(File.readlines('example5.txt').map(&:chomp))
Solver.new(File.readlines('example6.txt').map(&:chomp))
Solver.new(File.readlines('example7.txt').map(&:chomp))
Solver.new(File.readlines('example8.txt').map(&:chomp))
Solver.new(File.readlines('example9.txt').map(&:chomp))
Solver.new(File.readlines('example10.txt').map(&:chomp))

# 81 * 2875 = 232875 -> too high
#             230000 -> too high
# Outcome: 81 * 2773 = 224613 --> wrong
# Outcome: 80 * 2773 = 221840 --> too low
# Outcome: 79 * 2692 = 212668 --> wrong
Solver.new(File.readlines('input.txt').map(&:chomp))
