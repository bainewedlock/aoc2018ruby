# stolen from https://www.youtube.com/watch?v=WiNkRStebpQ
$ns = File.read("input1.txt").split.map &:to_i

def read_tree
  nc, nm = $ns.shift, $ns.shift
  children = Array.new(nc) { read_tree }
  metadata = Array.new(nm) { $ns.shift  }
  [children, metadata]
end

def sum_metadata(children, metadata)
  metadata.sum +
  children.map{|c| sum_metadata(*c)}.sum
end

def value(children, metadata)
  if children.empty?
    metadata.sum
  else
    metadata.map do |m|
      c = children[m-1] 
      c ? value(*c) : 0
    end.sum
  end
end

root = read_tree
puts sum_metadata(*root)
puts value(*root)
