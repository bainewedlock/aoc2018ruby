class Solver
  def initialize(serial_number)
    @serial_number = serial_number
  end

  def calc_power(x, y)
    power_level(x + 10, y, @serial_number).to_s[-3].to_i - 5
  end

  def power_level(x, a, b)
    a * (x*x) + b * x
  end

  def start
    matrix = Hash.new 0
    1.upto(300).each do |x|
      1.upto(300).each do |y|
        p = calc_power(x, y)
        -2.upto(0).each do |dx|
          -2.upto(0).each do |dy|
            matrix["#{x+dx},#{y+dy}"] += p
          end
        end
      end
    end
    matrix.sort_by{|k,v| -v}.first
  end
end

p Solver.new(1133).start
