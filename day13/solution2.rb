class TextParser
  def initialize(lines)
    parse(lines)
    tick_count = 0
    loop do
      # debug
      tick_count += 1
      tick
      break if @carts.size <= 1
    end
    puts "remaining cart location: #{@carts[0].pos}"
    puts "tick_count:#{tick_count}"
  end
  def debug
    maxx = @tracks.keys.map(&:first).max
    maxy = @tracks.keys.map(&:last).max
    (0..maxy).each do |y|
      (0..maxx).each do |x|
        if @carts.any? { |cart| cart.pos == [x, y] }
          print '#'
          next
        end
        if @tracks.include? [x, y]
          print '|'
        else
          print ' '
        end
      end
      puts
    end
    puts
  end
  def tick
    # wrong: 105,39
    # wrong: 58,42
    # wrong: 117,79
    # wrong: 13,78
    # test: 136, 8
    crashed_carts = []
    @carts.sort_by! do |cart|
      cart.pos.reverse
    end
    occupied = @carts.map(&:pos)
    @carts.each do |cart|
      occupied.delete(cart.pos)
      cart.move do |pos, direction|
        @tracks[pos].possible_directions_for(direction)
      end
      if occupied.include? cart.pos
        both_crashed = @carts.select { |test| test.pos == cart.pos }
        crashed_carts.push cart # current moving crashes first(?)
        crashed_carts.push [both_crashed-[cart]].first
        # crashed_carts += both_crashed
      else
        occupied.push cart.pos
      end
    end
    crashed_carts.each do |cart|
      @carts -= [cart]
      break if @carts.size == 1
    end
  end
  def parse(lines)
    @tracks = {}
    @carts = []
    lines.each.with_index do |line, y|
      line.chars.each.with_index do |char, x|
        Track.try_parse(char) do |track|
          @tracks[[x, y]] = track
        end
        Cart.try_parse(x, y, char) do |cart|
          @carts.push cart
        end
      end
    end
  end
end

class Track
  def self.try_parse(char)
    case char
    when '-', '<', '>' then yield create_with(:left, :left, :right, :right)
    when '|', '^', 'v' then yield create_with(:up, :up, :down, :down)
    when '/' then yield create_with(:left, :down, :up, :right)
    when '\\' then yield create_with(:right, :down, :up, :left)
    when '+' then yield Intersection.new()
    end
  end
  def self.create_with(*directions)
    Track.new(directions.each_slice(2).map do |from, to|
      [[from, to], [to, from]]
    end.flatten(1).to_h)
  end
  def possible_directions_for(direction)
    [@map[direction]]
  end
  private
  def initialize(map)
    @map = map
  end
end

class Intersection
  def possible_directions_for(direction)
    circle = [:left, :up, :right, :down] * 3
    current = circle.index(direction) + 4
    circle.drop(current - 1).take(3)
  end
end

class Cart
  attr_reader :pos
  def self.try_parse(x, y, char)
    case char
    when '<' then yield Cart.new(x, y, :left )
    when '^' then yield Cart.new(x, y, :up   )
    when 'v' then yield Cart.new(x, y, :down )
    when '>' then yield Cart.new(x, y, :right)
    end
  end
  def move
    @direction = choose_from yield(@pos, @direction)
    @pos = @pos.send(@direction)
  end
  def choose_from(directions)
    return directions[0] if directions.size == 1
    choice = directions[@next_intersection_choice]
    @next_intersection_choice = (@next_intersection_choice + 1) % 3
    return choice
  end
  private
  def initialize(x, y, direction)
    @pos = [x, y]
    @direction = direction
    @next_intersection_choice = 0
  end
end

class Array
  def down
    [self[0], self[1] + 1]
  end
  def up
    [self[0], self[1] - 1]
  end
  def left
    [self[0] - 1, self[1]]
  end
  def right
    [self[0] + 1, self[1]]
  end
end

TextParser.new(File.readlines('input2.txt').map(&:chomp))
