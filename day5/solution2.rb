class Solver
  LETTERS = ('a'..'z')
  TRIGGER_PATTERN = Regexp.new LETTERS.map{|c| [ c + c.upcase, c.upcase + c ]}.flatten.join('|')
  def input_line(line)
    sizes = []
    LETTERS.each do |l|
      size = collapse(remove_letter(line, l)).size
      sizes.push size
      puts "#{l} -> #{size}"
    end
    puts "result: #{sizes.max} units"
  end
  def remove_letter(line, letter)
    line.gsub(Regexp.new(letter, 'i'), '')
  end
  def collapse(line)
    line.gsub!(TRIGGER_PATTERN , '') while line.match TRIGGER_PATTERN
    line
  end
end

Solver.new.input_line(File.read("input1.txt").chomp)
