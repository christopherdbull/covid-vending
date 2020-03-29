require 'db_adapter'
require 'change'

RSpec.describe(DBAdapter) do
  describe '#update_change' do
    let(:change) { Change.new({'20p' => 5, '50p' => 2}) }
    it 'updates change quantities' do
      adapter = DBAdapter.new
      fiftyp_quantity = adapter.change.where(denomination: '50p').first[:quantity]
      twentyp_quantity = adapter.change.where(denomination: '20p').first[:quantity]
      adapter.update_change(change: change, pos_neg: :pos)
      expect(adapter.change.where(denomination: '50p').first[:quantity]).to eq(fiftyp_quantity + 2)
      expect(adapter.change.where(denomination: '20p').first[:quantity]).to eq(twentyp_quantity + 5)
      fiftyp_quantity = adapter.change.where(denomination: '50p').first[:quantity]
      twentyp_quantity = adapter.change.where(denomination: '20p').first[:quantity]
      adapter.update_change(change: change, pos_neg: :neg)
      expect(adapter.change.where(denomination: '50p').first[:quantity]).to eq(fiftyp_quantity - 2)
      expect(adapter.change.where(denomination: '20p').first[:quantity]).to eq(twentyp_quantity - 5)
    end
  end
end