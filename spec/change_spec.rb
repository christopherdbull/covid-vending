require 'change'

RSpec.describe(Change) do
  it 'assigns change amounts and cleans any invalid ones' do
    input = {'50p' => 20, '5op' => 20, 'derp' => 20, '£1' => nil}
    expect(Change.new(input).values).to eq({'50p' => 20})
  end

  describe '#total' do
    it 'correectly sums the change provided' do
      change = Change.new({'£1' => 1, '20p' => 5, '50p' => 2})
      expect(change.total).to eq(300)
    end
  end

  describe '#add_coin' do
    it 'adds the coin to values qty' do
      change = Change.new({'£1' => 1, '20p' => 5, '50p' => 2})
      change.add_coin('£1')
      expect(change.values['£1']).to eq(2)
      change.add_coin('1p')
      expect(change.values['1p']).to eq(1)
    end
  end
end