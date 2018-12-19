class Solver
  def initialize(lines)
    @examples = []
    parse_lines(lines)
    search @examples.map { |example| [example.opcode, example.matching_ops] }.to_h
    execute_program
  end

  def execute_program
    cpu = Cpu.new
    @program.each do |opcode, a, b, c|
      cpu.eval @map[opcode][0], a, b, c
    end
    p cpu.registers(0, 0)
  end

  def search(map)
    if map.all? { |k, v| v.size == 1 }
      @map = map
      return :solved
    end

    (picked_key, candidates) = map.select { |k, v| v.size > 1 }.min_by { |k, v| v.size }

    candidates.each do |candidate|
      next_map = (map.map do |k, v|
        if k == picked_key
          [k, [candidate]]
        else
          [k, v-[candidate]]
        end
      end.to_h)
      next if next_map.any? { |k, v| v.size == 0 }
      return if search(next_map) == :solved
    end
    return :dead_end
  end

  def parse_lines(lines)
    lines.each_slice(4).each do |four_lines|
      break unless four_lines[0].start_with? 'Before'
      parse_example(*four_lines.take(3))
    end

    @program = lines.drop(@examples.size * 4).reject(&:empty?).map do |line|
      line.split.map &:to_i
    end
  end

  def parse_example(a, b, c)
    before = a.gsub(/[\[\],]/, '').split[1..-1].map(&:to_i)
    after  = c.gsub(/[\[\],]/, '').split[1..-1].map(&:to_i)
    instruction = b.split.map(&:to_i)
    @examples.push Example.new(before, instruction, after)
  end
end

class Example
  def initialize(before, instruction, after)
    @before = before
    @instruction = instruction
    @after = after
  end

  def matching_ops
    Cpu.oplist.select do |op|
      c = Cpu.new(@before)
      c.eval op, *@instruction[1..3]
      @after == c.registers(0, 3)
    end
  end

  def opcode
    @instruction[0]
  end
end

class Cpu
  def initialize(initial_values=[])
    @reg = Hash.new 0
    initial_values.each.with_index do |value, i|
      @reg[i] = value
    end
  end

  def ___addr(a, b)
    @reg[a] + @reg[b]
  end

  def ___addi(a, b)
    @reg[a] + b
  end

  def ___mulr(a, b)
    @reg[a] * @reg[b]
  end

  def ___muli(a, b)
    @reg[a] * b
  end

  def ___banr(a, b)
    @reg[a] & @reg[b]
  end

  def ___bani(a, b)
    @reg[a] & b
  end

  def ___borr(a, b)
    @reg[a] | @reg[b]
  end

  def ___bori(a, b)
    @reg[a] | b
  end    

  def ___setr(a, b)
    @reg[a]
  end

  def ___seti(a, b)
    a
  end

  def ___gtir(a, b)
    a > @reg[b] ? 1 : 0
  end

  def ___gtri(a, b)
    @reg[a] > b ? 1 : 0
  end

  def ___gtrr(a, b)
    @reg[a] > @reg[b] ? 1 : 0
  end

  def ____eqir(a, b)
    a == @reg[b] ? 1 : 0
  end

  def ___eqri(a, b)
    @reg[a] == b ? 1 : 0
  end

  def ___eqrr(a, b)
    @reg[a] == @reg[b] ? 1 : 0
  end

  def eval(op, a, b, c)
    @reg[c] = send(op, a, b)
  end

  def registers(first, last)
    (first..last).map do |i|
      @reg[i]
    end
  end

  def self.oplist
    Cpu.new.methods.select do |method| method.to_s.start_with? '___' end
  end
end

Solver.new(File.readlines('input1.txt').map(&:chomp))
