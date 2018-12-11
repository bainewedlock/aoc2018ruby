
class Solver
  PATTERN = /#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/
  def start(input)
    @visited = {}
    @overlapped = {}
    @overlappers = {}
    @indices = []
    input.each do |line|
      input_line line
    end
    p @indices - @overlappers.keys
  end
  def input_line(line)
    (index, x, y, w, h) = line.match(PATTERN).captures.map(&:to_i)
    @index = index
    @indices.push index
    square x, y, w, h
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
    if @visited.include? coordinate
      @overlapped[coordinate] = @index
      @overlappers[@index] = true
      @overlappers[@visited[coordinate]] = true
    end
    @visited[coordinate] = @index
  end
end


Solver.new.start(File.readlines("input1.txt").map(&:chomp))
