require_relative 'map_builder'
require 'set'

class Solver
  def initialize(map, viewport_file)
    @viewport_file = viewport_file
    @ymax = map.map { |x, y| y }.max
    @map = map
    @visited = Set[]
    pos = [500, 0]
    search(pos)
    debug
    puts "visited: #{(@visited-pos).size-1}"
  end

  def search(pos)
    time_debug
    if pos.y > @ymax
      return :stop
    end

    visit pos

    unless %i[left right down].any? { |direction| free?(pos.send(direction)) }
      return :settle
    end

    unless @map.include? pos.down
      case search(pos.down)
      when :settle
        return spread(pos)
      else
        return :stop
      end
    end

    return spread(pos)
  end

  def spread(center)
    pos = center

    left_stop = false
    loop do
      pos = pos.left
      break if blocked? pos
      case search(pos)
      when :stop
        left_stop = true
        break
      end
    end

    pos = center
    right_stop = false
    loop do
      pos = pos.right
      break if blocked? pos
      case search(pos)
      when :stop
        right_stop = true
        break
      end
    end

    return left_stop || right_stop ? :stop : :settle
  end

  def free?(pos)
    return false if @map.include? pos
    return false if @visited.include? pos
    return true
  end

  def blocked?(pos)
    !free?(pos)
  end

  def visit(pos)
    return if @visited.include? pos
    @visited += [pos]
  end

  def update_viewport
    input = File.read(@viewport_file)
    exit if input.include?('x')
    width, height, @left, @top = input.chomp.split.map(&:to_i)
    @bottom = @top + height - 1
    @right = @left + width - 1
  end

  def time_debug
    debug if @last_debug.nil? || (Time.now - @last_debug) * 1000.0 > 1000
  end

  def debug
    @last_debug = Time.now
    update_viewport
    xdigits = [@left, @right].map(&:to_s).map(&:size).max
    ydigits = [@top, @bottom].map(&:to_s).map(&:size).max

    (xdigits-1).downto(0) do |t|
      print ' ' * ydigits + ' '
        @left.upto(@right) do |x|
        print x.to_s.rjust(xdigits).reverse[t]
      end
      puts
    end

    @top.upto(@bottom) do |y|
      print y.to_s.rjust(2) + ' '
      @left.upto(@right) do |x|
        if [x, y] == [500, 0]
          print '+'
          next
        end
        if @visited.include? [x, y]
          print '|'
          next
        end
        if @map.include? [x, y]
          print '#'
        else
          print '.'
        end
      end
      puts
    end
  end
end

class Array
  def left
    [x - 1, y]
  end

  def right
    [x + 1, y]
  end

  def up
    [x, y - 1]
  end

  def down
    [x, y + 1]
  end

  def x
    self[0]
  end

  def y
    self[1]
  end
end


# input = 'input1.txt'
input = 'example1.txt'
viewport = input.split('.')[0] + "_viewport.txt"

Solver.new MapBuilder.new(File.readlines(input).map(&:chomp)).map, viewport

