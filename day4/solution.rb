class Solver
  def input_lines(input)
    @records = []
    input.sort.each do |line|
      do_line line
    end
    report
  end
  def do_line(line)
    line.match /^\[(\S+) \d+:(\d+)\] (.*)$/
    @date = $1
    @minute = $2.to_i
    do_message $3
  end
  def do_message(message)
    case message
    when /Guard #(\d+) begins shift/
      do_guard $1.to_i
    when /wakes up/
      do_wake
    when /falls asleep/
      do_sleep
    end
  end
  def do_guard(n)
    @guard = n
  end
  def do_sleep
    @sleep_start = @minute
  end
  def do_wake
    (@sleep_start...@minute).each do |m|
      @records.push({ date: @date, guard: @guard, minute: m })
    end
  end
  def report
    (g, m) = @records
      .group_by{|x|[x[:guard], x[:minute]]}
      .max_by{|k,v|v.size}
      .first
    puts "#{g}x#{m}=#{g*m}"
  end
end

Solver.new.input_lines(File.readlines("input1.txt").map(&:chomp))
