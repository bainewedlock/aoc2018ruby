
def solve(input)
  x = 0
  y = 0
  input.each do |line|
    count = count_chars(line)
    x+=1 if count.include?(2)
    y+=1 if count.include?(3)
  end
  "#{x}*#{y}=#{x*y}"
end

def count_chars(text)
  text.chars.group_by(&:itself).map do |ch, occurances|
    occurances.size
  end
end



p solve("abcdef contains no letters that appear exactly two or three times.
bababc contains two a and three b, so it counts for both.
abbcde contains two b, but no letter appears exactly three times.
abcccd contains three c, but no letter appears exactly two times.
aabcdd contains two a and two d, but it only counts once.
abcdee contains two e.
ababab contains three a and three b, but it only counts once.".lines.map{|l| l.split.first})

p solve(File.readlines("input.txt"))
