class Solver
  def input_line(line)
    @numbers = line.split.map &:to_i
    @meta_sum = 0
    @stack = ['header']
    send @stack.pop while @numbers.any?
    puts "solution: #{@meta_sum}"
  end
  def header
    (children, metas) = @numbers.shift 2
    metas.times    do @stack.push 'meta'   end
    children.times do @stack.push 'header' end
  end
  def meta
    @meta_sum += @numbers.shift
  end
end

Solver.new.input_line(File.read("input1.txt"))
