require_relative 'linked_list'
require 'rspec'

describe LinkedList do
  it 'works with a single value' do
    l = LinkedList.new
    l.insert 1
    expect(l.remove).to eq 1
  end
  it 'can rotate forward' do
    l = LinkedList.new
    l.insert 3
    l.insert 2
    l.insert 1
    l.rotate_forward 2
    expect(l.remove).to eq 3
  end
  it 'can rotate backward' do
    l = LinkedList.new
    l.insert 3
    l.insert 2
    l.insert 1
    l.rotate_backward 2
    expect(l.remove).to eq 2
  end
  it 'removes value' do
    l = LinkedList.new
    l.insert 2
    l.insert 1
    l.remove
    expect(l.remove).to eq 2
    expect(l.remove).to eq nil
  end
end
