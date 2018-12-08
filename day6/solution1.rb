class Solver
  def input_lines(lines)
    @nearest_point_list = []
    @infinite_areas = {}
    @points = lines.map do |line|
      line.match /(\d+), (\d+)/
      [ $1.to_i, $2.to_i ]
    end

    calculate_bounds
    visit_all_coordinates
    remove_infinite_areas
    print_result
  end
  def print_result
    (point, area) = @nearest_point_list
      .group_by {|p| p}
      .max_by {|k,v| v.size}
    puts "biggest finite area: #{point} size=#{area.size}"
  end
  def remove_infinite_areas
    @nearest_point_list -= @infinite_areas.keys
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
    distance_to_points = @points.group_by do |px, py|
      (px-x).abs + (py-y).abs
    end
    min_distance = distance_to_points.keys.min
    nearest_points = distance_to_points[min_distance]
    single_nearest_point_at(nearest_points.first, x, y) unless nearest_points.count > 1
  end
  def single_nearest_point_at(p, x, y)
    @nearest_point_list.push p
    @infinite_areas[p] = 1 if at_border?(x, y)
  end
  def at_border?(x, y)
    x == @x_range.min || x == @x_range.max ||
    y == @y_range.min || y == @y_range.max
  end
end

Solver.new.input_lines(File.readlines("input1.txt").map(&:chomp))
