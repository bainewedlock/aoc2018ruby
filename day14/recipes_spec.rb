require_relative 'recipes'
require 'rspec'

describe Recipes do
  it 'starts' do
    expect(Recipes.new.debug).to eq "(3)[7]"
  end
  it 'returns scores of elves' do
    r = Recipes.new
    expect(r.elves_scores.sum).to eq 10
  end
  it 'appends scores' do
    r = Recipes.new
    r.append [3, 4]
    expect(r.debug).to eq "(3)[7] 3  4 "
  end
  it 'moves elves' do
    r = Recipes.new
    r.append [3, 4]
    r.move(0, 3)
    expect(r.debug).to eq " 3 [7] 3 (4)"
  end
  it 'cycles' do
    r = Recipes.new
    r.append [3, 4]
    r.move(0, 6)
    expect(r.debug).to eq " 3 [7](3) 4 "
  end
end
