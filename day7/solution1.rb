class Step
  attr_reader :id
  attr_reader :finished
  def initialize(id)
    @id = id
    @required_steps = []
  end
  def add_required_step(n)
    @required_steps.push n
  end
  def can_begin?
    @required_steps.all? &:finished
  end
  def begin!
    @finished = true
  end
end

class Solver
  def input_lines(lines)
    @steps = {}
    @solution = ""
    lines.each do |line|
      input_line(line)
    end
    solve_recursively @steps.values
    puts @solution
  end
  def input_line(line)
    line.match /Step (.) must be finished before step (.) can begin/
    initialize_step $1
    initialize_step $2
    @steps[$2].add_required_step @steps[$1]
  end
  def initialize_step(id)
    @steps[id] = Step.new(id) unless @steps.include? id
  end
  def solve_recursively(remaining_steps)
    return if remaining_steps.empty?
    n = remaining_steps.select(&:can_begin?).min_by(&:id)
    n.begin!
    @solution += n.id
    solve_recursively(remaining_steps - [n])
  end
end


Solver.new.input_lines(File.readlines('input1.txt').map(&:chomp))
