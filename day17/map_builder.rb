require 'set'

class MapBuilder
  def initialize(lines)
    @map = {}
    lines.each do |line|
      match_data = /x=(.*), y=(.*)/.match normalize(line)
      parse_range(match_data[1]).each do |x|
        parse_range(match_data[2]).each do |y|
          @map[[x, y]] = 1
        end
      end
    end
  end

  def map
    Set.new @map.keys
  end

  def normalize(line)
    return line if line.start_with? 'x'
    line.split(', ').reverse.join(', ')
  end

  def parse_range(range_text)
    limits = range_text.split('..').map(&:to_i)
    (limits.first..limits.last)
  end
end

