require 'calculator'
require 'db_adapter'

RSpec.describe(Calculator) do
  let(:change) { Change.new({'£1' => 1, '20p' => 5, '50p' => 2}) }
  describe '#enough_change_presented?' do
    it 'is true when change total > purchase total' do
      calculator = Calculator.new(purchase_total: 100, change_presented: change)
      expect(calculator.enough_change_presented?).to eq(true)
    end
  end

  describe '#change_returned' do
    let(:current_change) { DBAdapter.new.change.all }
    let(:calculator) { Calculator.new(purchase_total: 100, change_presented: change) }

    it 'sums to the total difference between supplied and purchased price' do
      expect(calculator.change_returned(current_change).total).to eq(change.total - 100)
    end

    it 'returns non-empty change' do
      expect(calculator.change_returned(current_change).values.count).to_not eq(0)
    end

    it 'doesnt include unavailable coins' do
      DBAdapter.new.change.where(denomination: '50p').delete
      expect(calculator.change_returned(current_change).values).to_not include('50p')
      DBAdapter.new.change.insert(denomination: '50p', quantity: 100)
    end

    it 'throws an error if change cant be made up' do
      expect {
        calculator.change_returned({})
      }.to raise_error(UnableToBuildChangeError)
    end
  end
end