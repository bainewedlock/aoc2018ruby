class Solver
  def input_line(line)
    trigger_pattern = Regexp.new ('a'..'z').map{|c| [ c + c.upcase, c.upcase + c ]}.flatten.join('|')
    line.gsub!(trigger_pattern, '') while line.match trigger_pattern
    puts "result: #{line.size} units"
  end
end

Solver.new.input_line(File.read("input1.txt").chomp)
