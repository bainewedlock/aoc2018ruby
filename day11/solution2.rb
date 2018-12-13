class Solver
  SIZE = 300
  def initialize(serial_number, square_sizes)
    @serial_number = serial_number
    @square_sizes = square_sizes
    puts "starting serial_number:#{serial_number} square_sizes:#{square_sizes}"
    prepare_cache
    start
  end

  def calc_power(x, y)
    power_level(x + 10, y, @serial_number).to_s[-3].to_i - 5
  end

  def power_level(x, a, b)
    a * (x * x) + b * x
  end

  def at(x, y)
    "#{x}:#{y}"
  end

  def prepare_cache
    @sum_down_right = Hash.new 0
    (SIZE - 1).downto(0).each do |y|
      line_power = 0
      (SIZE - 1).downto(0).each do |x|
        line_power += calc_power(x, y)
        @sum_down_right[at(x, y)] = @sum_down_right[at(x, y + 1)] + line_power
      end
    end
  end

  def start
    max_square_sum = nil
    max = nil
    @square_sizes.each do |s|
      (0..SIZE - s).each do |y|
        (0..SIZE - s).each do |x|
          from_left_top     = @sum_down_right[at(x,         y)]
          from_right_top    = @sum_down_right[at(x + s,     y)]
          from_left_bottom  = @sum_down_right[at(x,     y + s)]
          from_right_bottom = @sum_down_right[at(x + s, y + s)]
          square_sum = from_left_top + from_right_bottom - from_right_top - from_left_bottom
          next unless max_square_sum.nil? || square_sum > max_square_sum
          max_square_sum = square_sum
          max = [x, y, s]
        end
      end
    end
    puts "max: #{max.join(',')} (sum: #{max_square_sum})"
  end
end

Solver.new(18, (3..3))
Solver.new(1133, (1..300)).start
