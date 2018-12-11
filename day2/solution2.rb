
def solve(input)
  solve_sorted(input.sort)
end

def solve_sorted(input)
  input.each_cons(2).each do |a, b|
    return remove_differences(a, b) if count_differences(a, b) == 1
  end
  return "not found"
end

def count_differences(a, b)
  a.chars.zip(b.chars).select{|a, b| a != b}.size
end

def remove_differences(a, b)
  a.chars.zip(b.chars).select{|a, b| a == b}.map(&:first).join
end

p solve("abcde
fghij
klmno
pqrst
fguij
axcye
wvxyz".lines.map{|l| l.split.first})

p solve(File.readlines("input.txt").map{|l| l.chomp})
