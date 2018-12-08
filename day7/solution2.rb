class Step
  attr_reader :id
  def initialize(id, duration)
    @id = id
    @required_steps = []
    @duration = duration
  end
  def add_required_step(n)
    @required_steps.push n
  end
  def can_begin?
    @required_steps.all? &:finished
  end
  def tick
    @duration -= 1
  end
  def finished
    @duration == 0
  end
end

class Workers
  attr_reader :elapsed_seconds
  def initialize(capacity)
    @elapsed_seconds = 0
    @steps = []
    @capacity = capacity
  end
  def at_full_capacity
    @steps.size == @capacity
  end
  def begin(new_step)
    @steps.push new_step
  end
  def tick
    # debug
    @steps.each &:tick
    @steps.reject! &:finished
    @elapsed_seconds += 1
  end
  def debug
    puts "#{elapsed_seconds}\t#{@steps.map(&:id).join("\t")}"
  end
  def idle
    @steps.empty?
  end
end

class Solver
  def initialize(worker_count, extra_duration)
    @workers = Workers.new(worker_count)
    @extra_duration = extra_duration
  end
  def input_lines(lines)
    @steps = {}
    lines.each do |line|
      input_line(line)
    end
    enqueue_recursively @steps.values
    @workers.tick until @workers.idle
    puts "solution: #{@workers.elapsed_seconds}"
  end
  def input_line(line)
    line.match /Step (.) must be finished before step (.) can begin/
    initialize_step $1
    initialize_step $2
    @steps[$2].add_required_step @steps[$1]
  end
  def initialize_step(id)
    create_step(id) unless @steps.include? id
  end
  def create_step(id)
    @steps[id] = Step.new id, duration_for(id)
  end
  def duration_for(step_id)
    ('A'..'Z').to_a.index(step_id) + 1 + @extra_duration
  end
  def enqueue_recursively(remaining_steps)
    return if remaining_steps.empty?
    @workers.tick while remaining_steps.none?(&:can_begin?)
    @workers.tick while @workers.at_full_capacity
    step = remaining_steps.select(&:can_begin?).min_by(&:id)
    @workers.begin step
    enqueue_recursively remaining_steps-[step]
  end
end

Solver.new(5, 60).input_lines(File.readlines('input1.txt').map(&:chomp))
