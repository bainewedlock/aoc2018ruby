class TextParser
  def initialize(lines)
    parse(lines)
    loop do
      tick
      break if @carts.size <= 1
    end
    puts "remaining cart location: #{@carts[0].pos}"
  end

  def tick
    collision_check = CollisionCheck.new(@tracks, @carts)
    @carts.sort_by! do |cart| cart.pos.reverse end
    @carts.each do |cart|
      collision_check.before_move(cart)
      directions = @tracks[cart.pos].possible_directions_for(cart.direction)
      cart.move_in_one_of(directions)
      collision_check.after_move(cart)
    end
    @carts -= collision_check.crashed_carts
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

class CollisionCheck
  attr_reader :crashed_carts
  def initialize(tracks, carts)
    @tracks = tracks
    @carts = carts
    @occupied = carts.map(&:pos)
    @crashed_carts = []
  end

  def before_move(cart)
    @occupied.delete cart.pos
  end

  def after_move(cart)
    if @occupied.include? cart.pos
      other = (@carts - [cart]).find { |test| test.pos == cart.pos }
      @occupied.delete other.pos
      @crashed_carts.push cart
      @crashed_carts.push other
    else
      @occupied.push cart.pos
    end
  end
end

class Track
  def self.try_parse(char)
    case char
    when '-', '<', '>' then yield with_routes(:left,  :left, :right, :right)
    when '|', '^', 'v' then yield with_routes(:up,    :up,   :down,  :down)
    when '/'           then yield with_routes(:left,  :down, :up,    :right)
    when '\\'          then yield with_routes(:right, :down, :up,    :left)
    when '+'           then yield Intersection.new
    end
  end

  def self.with_routes(*directions)
    Track.new(directions.each_slice(2).flat_map do |from, to|
      [[from, to], [to, from]]
    end.to_h)
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
    circle = %i[left up right down] * 3
    start = circle.index(direction) + 4
    circle.drop(start - 1).take(3)
  end
end

class Cart
  attr_reader :pos
  attr_reader :direction
  def self.try_parse(x, y, char)
    case char
    when '<' then yield Cart.new(x, y, :left)
    when '^' then yield Cart.new(x, y, :up)
    when 'v' then yield Cart.new(x, y, :down)
    when '>' then yield Cart.new(x, y, :right)
    end
  end

  def move_in_one_of(directions)
    @direction = choose_from(directions)
    @pos = @pos.send(@direction)
  end

  def choose_from(directions)
    return directions[0] if directions.size == 1
    choice = directions[@next_intersection_choice]
    @next_intersection_choice = (@next_intersection_choice + 1) % 3
    choice
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
