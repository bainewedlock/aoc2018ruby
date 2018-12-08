class Solver
  def input_lines(lines)
    @area = []
    @points = lines.map do |line|
      line.match /(\d+), (\d+)/
      [ $1.to_i, $2.to_i ]
    end

    calculate_bounds
    visit_all_coordinates
    print_result
  end
  def print_result
    puts "biggest area size=#{@area.size}"
  end
  def visit_all_coordinates
    @x_range.each do |x|
      @y_range.each do |y|
        visit x, y
      end
    end
  end
  def calculate_bounds
    @x_range, @y_range = @points.transpose.map {|c| c.min .. c.max}
  end
  def visit(x, y)
    total_distance = @points.sum do |px, py|
      (px-x).abs + (py-y).abs
    end
    valid_distance_at(x, y) if total_distance < 10000
  end
  def valid_distance_at(x, y)
    @area.push [x, y]
  end
  def at_border?(x, y)
    x == @x_range.min || x == @x_range.max ||
    y == @y_range.min || y == @y_range.max
  end
end

Solver.new.input_lines(File.readlines("input1.txt").map(&:chomp))
