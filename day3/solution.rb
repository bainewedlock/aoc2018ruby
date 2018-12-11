
class Solver
  PATTERN = /@ (\d+),(\d+): (\d+)x(\d+)/
  def start(input)
    @visited = {}
    @overlapped = {}
    input.each do |line|
      input_line line
    end
    p @overlapped.size
  end
  def input_line(line)
    values = line.match(PATTERN).captures.map(&:to_i)
    square *values
  end
  def square(x, y, w, h)
    (0...w).to_a.product((0...h).to_a).each do |dx, dy|
      visit_at(x+dx, y+dy)
    end
  end
  def visit_at(x, y)
    visit "#{x}:#{y}"
  end
  def visit(coordinate)
    @overlapped[coordinate] = true if @visited[coordinate]
    @visited[coordinate] = true
  end
end


Solver.new.start(File.readlines("input1.txt").map(&:chomp))
