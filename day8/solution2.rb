class Node
  def initialize
    @children = []
    @metas = []
  end
  def add_child(child)
    @children.push child
  end
  def add_meta(meta)
    @metas.push meta-1
  end
  def value
    @children.any? ? value_of_children : @metas.sum
  end
  def value_of_children
    @metas.map {|m| @children[m]}
      .reject(&:nil?)
      .map(&:value)
      .sum
  end
end

class Solver
  def input_line(line)
    @numbers = line.split.map &:to_i
    @meta_sum = 0
    root = Node.new
    root.add_meta 1
    @stack = [['header', root]]
    @parent_node_stack = []
    send *@stack.pop while @numbers.any?
    puts "solution: #{root.value}"
  end
  def header(parent)
    n = Node.new
    parent.add_child n
    (children, metas) = @numbers.shift 2
    metas.times    do @stack.push ['meta',   n] end
    children.times do @stack.push ['header', n] end
  end
  def meta(node)
    node.add_meta @numbers.shift
  end
end

Solver.new.input_line(File.read("input1.txt"))
