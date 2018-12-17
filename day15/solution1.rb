# frozen_string_literal: true

class Solver
  def initialize(lines)
    parse_input lines

    @round = 0
    do_one_round until @game_over

    report
  end

  def do_one_round
    for monster in @monsters.sort_by(&:pos)
      monster.engage(@monsters) do |enemies|
        unless enemies.any?
          @game_over = true unless enemies.any?
          return
        end
        try_move(monster, enemies) unless monster.can_attack?(enemies)
        try_attack(monster, enemies)
      end
    end
    finish_round
    @game_over = true if we_have_a_winner
  end

  def we_have_a_winner
    @monsters.map(&:char).uniq.size < 2
  end

  def finish_round
    @round += 1
    puts "#{@round} rounds..." if @round % 10 == 0
  end

  def try_move(monster, enemies)
    target_positions = enemies.flat_map { |enemy| enemy.adjacent(@floors) }
    calculate_move(monster.pos, target_positions) do |step|
      @floors.push monster.pos
      monster.move(step)
      @floors.delete monster.pos
    end
  end

  def try_attack(monster, enemies)
    monster.attack(enemies) do |killed|
      @floors.push killed.pos
      @monsters.delete killed
    end
  end

  def calculate_move(start, targets)
    (paths, visited) = floodfill(start, targets.uniq, @floors, false)
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

  def report
    hitpoints = @monsters.map(&:hitpoints).sum
    puts "Outcome: #{@round} * #{hitpoints} = #{@round * hitpoints}"
  end
end

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

  def select_enemies(monsters)
    monsters.reject { |candidate| candidate.char == char }
  end

  def can_attack?(enemies)
    enemies.any? { |enemy| pos.neighbours.include? enemy.pos }
  end

  def attack(enemies)
    hittable = enemies
               .select { |enemy| pos.neighbours.include? enemy.pos }
               .min_by { |enemy| [enemy.hitpoints, enemy.pos] }
    if hittable
      hittable.damage
      yield hittable if hittable.hitpoints <= 0
    end
  end

  def damage
    @hitpoints -= 3
  end

  def move(step)
    @pos = @pos.send(step)
  end

  def adjacent(floors)
    floors & pos.neighbours
  end

  def engage(monsters)
    return if hitpoints <= 0
    yield select_enemies(monsters)
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
