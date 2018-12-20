class MapBuilder
  def initialize(lines, left, right, top, bottom)
    @left = left
    @right = right
    @top = top
    @bottom = bottom
    @map = {}
    lines.each do |line|
      match_data = /x=(.*), y=(.*)/.match normalize(line)
      parse_range(match_data[1]).each do |x|
        parse_range(match_data[2]).each do |y|
          @map[[x, y]] = 1
        end
      end
    end
    @xmin = @map.keys.map { |x, y| x }.min
    @xmax = @map.keys.map { |x, y| x }.max
    @ymin = @map.keys.map { |x, y| y }.min
    @ymax = @map.keys.map { |x, y| y }.max
    debug
  end

  def normalize(line)
    return line if line.start_with? 'x'
    line.split(', ').reverse.join(', ')
  end

  def parse_range(range_text)
    limits = range_text.split('..').map(&:to_i)
    (limits.first..limits.last)
  end

  def debug
    xdigits = [@left, @right].map(&:to_s).map(&:size).max
    ydigits = [@top, @bottom].map(&:to_s).map(&:size).max

    (xdigits-1).downto(0) do |t|
      print ' ' * ydigits + ' '
        @left.upto(@right) do |x|
        print x.to_s.rjust(xdigits).reverse[t]
      end
      puts
    end

    @top.upto(@bottom) do |y|
      print y.to_s.rjust(2) + ' '
      @left.upto(@right) do |x|
        if [x, y] == [500, 0]
          print '+'
          next
        end
        if @map.include? [x, y]
          print '#'
        else
          print '.'
        end
      end
      puts
    end

  end
end

MapBuilder.new(File.readlines('example1.txt').map(&:chomp), 494, 507, 0, 13)
# b = MapBuilder.new(File.readlines('input1.txt').map(&:chomp), 450, 550, 0, 40)


