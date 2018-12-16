# frozen_string_literal: true

class Solver
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
    debug
    99999999.times do |round|
      for monster in @monsters.clone
        enemies = enemies_of(monster.char)
        if enemies.none?
          puts "game over after #{round+1} rounds"
          debug
          hitpoints = @monsters.map(&:hitpoints).sum
          puts "Outcome: #{round+1} * #{hitpoints} = #{(round+1)* hitpoints}"
          exit
        end

        hittable = enemies.find { |enemy| monster.pos.neighbours.include? enemy.pos }

        unless hittable
          in_range = enemies.flat_map { |enemy| in_range_of(enemy.pos) }.uniq
          in_range.specialsort!
          move(monster.pos, in_range) do |step|
            @floors.push monster.pos
            monster.move step
            @floors.delete monster.pos
          end
        end

        hittable = enemies.select { |enemy| monster.pos.neighbours.include? enemy.pos }.min_by { |enemy| [enemy.hitpoints, enemy.pos.y, enemy.pos.x] }

        if hittable
          hittable.damage(3) do
            @floors.push hittable.pos
            @monsters.delete(hittable)
          end
        end
      end
      puts "after #{round+1} rounds"
      debug
    end
  end

  def move(start, targets)
    paths = [[[start], []]]
    visited = [start]
    loop do
      paths.map! do |pos, steps|
        pos.last.neighbours_with_step.map do |neighbour, step|
          next if visited.include?(neighbour) or !@floors.include?(neighbour)
          [pos + [neighbour], steps + [step]]
        end
      end
      paths.flatten!(1)
      paths.reject!(&:nil?)

      if paths.empty?
        return
      end

      visited += paths.map { |pos, _| pos.last }

      found = paths.select { |pos, _| targets.include? pos.last }
      if found.any?
        path = found.min_by do |pos, steps|
          pos.map(&:reverse)
        end
        step = path[1][0]
        yield step
        return
      end
    end
  end

  def in_range_of(pos)
    pos.neighbours & @floors
  end

  def enemies_of(char)
    @monsters.reject { |monster| monster.char == char }
  end

  def debug
    for y in 0..@maxy
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
    @monsters.specialsort_by_pos!
  end
end

class Array
  def at(pos)
    found = find { |item| item.pos == pos }
    yield found if found
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
    [:right, :left, :down, :up].map do |step|
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
    puts "#{@char}:#{@hitpoints}" if @pos == [5, 4]
    yield if @hitpoints <= 0
  end

  def text
    "#{@char}(#{@hitpoints})"
  end
end

Solver.new(File.readlines('input.txt').map(&:chomp))
