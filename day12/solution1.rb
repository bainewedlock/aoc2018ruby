# frozen_string_literal: true

class String
  def clean
    chomp.tr('.', ',')
  end
end

class Solver
  def initialize(header, lines)
    @offset = 0
    @last_sum = 0
    @sum = 0
    @twenty_three_count = 0
    prepare_cache(lines)
    @state = header[/initial state: (\S+)/, 1]
    @generation = 0
    while @generation < 20000
      next_generation
      @generation += 1
      update_sum
      debug
    end
    update_sum
    report
  end

  def update_sum
    @last_sum = @sum
    @sum = (@state.chars.map.with_index do |c, i|
      c == '#' ? i + @offset : 0
    end.sum)
    @difference = @sum - @last_sum
    if @difference == 23
      @twenty_three_count += 1
    else
      @twenty_three_count = 0
    end
    if @twenty_three_count == 100
      @missing_generations = 50000000000 - @generation
      puts "#{@missing_generations * 23 + @sum}"
      exit
    end
  end

  def report
    puts "#{@difference} #{@twenty_three_count}"
  end

  def debug
    # puts "#{@generation.to_s.rjust(3)} sum:#{@sum}"
    # puts "#{@generation.to_s.rjust(3)}: #{@state} offset:#{@offset}"
  end

  def prepare_cache(input_lines)
    growing_states = input_lines.map do |line|
      line[/(.....) => (#)/, 1]
    end

    chars = [',', '#']
    @map =
      chars
      .product(chars)
      .product(chars).map { |combi| combi.flatten(1) }
      .product(chars).map { |combi| combi.flatten(1) }
      .product(chars).map { |combi| combi.flatten(1) }
      .map(&:join)
      .map do |combination|
        [combination, growing_states.include?(combination) ? '#' : ',']
      end.to_h
  end

  def next_generation
    state = (",,,,#{@state},,,,".chars.each_cons(5).map do |segment|
      @map[segment.join]
    end).join
    left_trimmed = state.gsub(/^,+/, '')
    @offset += (state.size - left_trimmed.size - 2)
    @state = left_trimmed.gsub(/,+$/, '')
  end
end

lines = File.readlines('input1.txt').map(&:clean)
Solver.new(lines[0], lines.drop(2))
