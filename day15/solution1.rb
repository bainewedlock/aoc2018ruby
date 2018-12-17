# frozen_string_literal: true

class Solver
  def floodfill(start, goals, map, something)
    paths = [[[start], []]]
    visited = [start]
    loop do
      new_paths = []
      paths.each do |pos, steps|
        pos.last.neighbours_with_step.map do |neighbour, step|
          next if visited.include?(neighbour) || !map.include?(neighbour)
          new_paths.push [pos + [neighbour], steps + [step]]
          visited.push neighbour unless goals.include? neighbour || something
        end
      end
      yield if new_paths.empty? # can't reach enemy
      paths = new_paths
      visited += paths.map { |pos, _| pos.last }
      return_candidates = paths.select { |pos, _| goals.include? pos.last }
      next unless return_candidates.any?
      return [return_candidates.map { |pos, _| pos }, visited]
    end
  end

  def calculate_move(start, targets)
    (xx, visited) = floodfill(start, targets, @floors, false) do
      return
    end
    target_pos = xx.min_by{|pos| pos[-1]}.last

    (xx, _) = floodfill(target_pos, [start], visited, true)
    pos_to_go = xx.map{|pos|pos[-2]}.min
    (_, step_to_take) = start.neighbours_with_step.find { |neighbour, _step| neighbour == pos_to_go }
    yield step_to_take
  end

  def initialize(lines)
    @floors = []
    @monsters = []
    @maxx = 0
    @maxy = 0
    lines.each.map.with_index do |line, y|
      line.chars.map.with_index do |char, x|
        pos = make_pos(x, y)
        @floors.push(pos) if char == '.'
        @monsters.push(Monster.new(pos, char)) if 'GE'.include? char
        @maxx = [@maxx, pos.x].max
        @maxy = [@maxy, pos.y].max
      end
    end
    @round = 0
    loop do
      @monsters.sort_by!(&:pos)
      for monster in @monsters.clone
        next if monster.hitpoints <= 0
        enemies = @monsters.reject { |candidate| candidate.char == monster.char }
        return game_over if enemies.none?

        hittable = enemies.find { |enemy| monster.pos.neighbours.include? enemy.pos }

        unless hittable
          any_enemy_reachable = enemies.any? { |enemy| !(enemy.pos.neighbours & @floors).empty? }
          next unless any_enemy_reachable # performance

          in_range = enemies.flat_map { |enemy| enemy.pos.neighbours & @floors}.uniq.sort
          calculate_move(monster.pos, in_range) do |step|
            @floors.push monster.pos
            monster.move step
            @floors.delete monster.pos
          end
        end

        hittable = enemies
                   .select { |enemy| monster.pos.neighbours.include? enemy.pos }
                   .min_by { |enemy| [enemy.hitpoints, enemy.pos.y, enemy.pos.x] }

        next unless hittable
        hittable.damage(3) do
          @floors.push hittable.pos
          @monsters.delete(hittable)
        end
      end
      @round += 1
      puts "#{@round} rounds..." if @round % 10 == 0 && @round > 50
      return game_over if @monsters.map(&:char).uniq.size < 2
    end
  end

  def game_over
    hitpoints = @monsters.map(&:hitpoints).sum
    puts "Outcome: #{@round} * #{hitpoints} = #{@round * hitpoints}"
  end
end

class Array
  def x
    self[1]
  end

  def y
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
    [y, x + 1]
  end

  def left
    [y, x - 1]
  end

  def up
    [y - 1, x]
  end

  def down
    [y + 1, x]
  end
end

def make_pos(x, y)
  [y, x]
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
    yield if @hitpoints <= 0
  end
end

Solver.new(File.readlines('example5.txt').map(&:chomp))
puts 'expected:           27730'
Solver.new(File.readlines('example6.txt').map(&:chomp))
puts 'expected:           36334'
Solver.new(File.readlines('example7.txt').map(&:chomp))
puts 'expected:           39514'
Solver.new(File.readlines('example8.txt').map(&:chomp))
puts 'expected:           27755'
Solver.new(File.readlines('example9.txt').map(&:chomp))
puts 'expected:           28944'
Solver.new(File.readlines('example10.txt').map(&:chomp))
puts 'expected:           18740'
Solver.new(File.readlines('input.txt').map(&:chomp))
