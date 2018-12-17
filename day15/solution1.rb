# frozen_string_literal: true

class Solver
  def floodfill(start, goals, map, return_all_paths)
    paths = [[start]]
    visited = [start]
    while paths.any?
      new_paths = []
      paths.each do |path|
        path.last.neighbours.map do |neighbour|
          next if visited.include?(neighbour) || !map.include?(neighbour)
          new_paths.push path + [neighbour]
          visited.push neighbour unless goals.include? neighbour || return_all_paths
        end
      end
      paths = new_paths
      visited += paths.map(&:last) if return_all_paths
      leading_to_goal = paths.select { |path| goals.include? path.last }
      return [leading_to_goal, visited] if leading_to_goal.any?
    end
  end

  def calculate_move(start, targets)
    (paths, visited) = floodfill(start, targets, @floors, false)
    return if paths.nil?
    target_pos = paths.map(&:last).min

    (paths,) = floodfill(target_pos, [start], visited, true)
    pos_to_go = paths.map { |path| path[-2] }.min

    yield all_directions.find { |step| start.send(step) == pos_to_go }
  end

  def parse_input(lines)
    @floors = []
    @monsters = []
    lines.each.map.with_index do |line, y|
      line.chars.map.with_index do |char, x|
        parse_char char, make_pos(x, y)
      end
    end
  end

  def parse_char(char, pos)
    case char
    when '.' then @floors.push(pos)
    when /G|E/ then @monsters.push(Monster.new(pos, char))
    end
  end

  def initialize(lines)
    parse_input lines

    @round = 0
    tick until @game_over

    report
  end

  def report
    hitpoints = @monsters.map(&:hitpoints).sum
    puts "Outcome: #{@round} * #{hitpoints} = #{@round * hitpoints}"
  end

  def tick
    @monsters.sort_by! &:pos
    for monster in @monsters.clone
      next if monster.hitpoints <= 0
      enemies = @monsters.reject { |candidate| candidate.char == monster.char }
      if enemies.none?
        @game_over = true
        return
      end

      hittable = enemies.find { |enemy| monster.pos.neighbours.include? enemy.pos }

      unless hittable
        any_enemy_reachable = enemies.any? { |enemy| !(enemy.pos.neighbours & @floors).empty? }
        next unless any_enemy_reachable # performance

        in_range = enemies.flat_map { |enemy| enemy.pos.neighbours & @floors }.uniq.sort
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

    @game_over = true if @monsters.map(&:char).uniq.size < 2
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
    all_directions.map do |step|
      send(step)
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

def all_directions
  %i[right left down up]
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
