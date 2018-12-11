
frequencies = {0 => 1}
f = 0
numbers = File.readlines("input.txt").map(&:to_i)

loop do
  numbers.each do |n|
    f += n
    if frequencies.include? f
      puts "#{f}"
      return
    else
      frequencies[f] = 1
    end
  end
  puts "again"
end

