class Solver
  def input_lines(input)
    @records = []
    input.sort.each do |line|
      do_line line
    end
    report
  end

  def do_line(line)
    match_data = /^\[(\S+) \d+:(\d+)\] (.*)$/.match line
    @date = match_data[1]
    @minute = match_data[2].to_i
    do_message match_data[3]
  end

  def do_message(message)
    case message
    when /wakes up/
      do_wake
    when /falls asleep/
      do_sleep
    else
      do_guard message[/Guard #(\d+) begins shift/, 1].to_i
    end
  end

  def do_guard(guard)
    @guard = guard
  end

  def do_sleep
    @sleep_start = @minute
  end

  def do_wake
    (@sleep_start...@minute).each do |minute|
      record = { date: @date, guard: @guard, minute: minute }
      @records.push record
    end
  end

  def report
    (guard, minute) =
      @records
      .group_by { |record| [record[:guard], record[:minute]] }
      .max_by { |_, records| records.size }
      .first
    puts "#{guard}x#{minute}=#{guard * minute}"
  end
end

Solver.new.input_lines(File.readlines('input1.txt').map(&:chomp))

