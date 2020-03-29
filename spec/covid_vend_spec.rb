require 'covid_vend'
require 'db_adapter'
require 'securerandom'
require 'change'

RSpec.describe(CovidVend) do
  let(:adapter) { DBAdapter.new }
  let(:covid_vend) { CovidVend.new }
  let(:rand_name) { SecureRandom.hex(4) }

  describe "#update_change" do
    it 'increments the quantity by the right amount' do
      expect {
        covid_vend.update_change(denomination: '£1', quantity: 20)
      }.to change {
        adapter.change.where(denomination: '£1').first[:quantity]
      }.by(20)
    end
  end

  describe "#update_item" do
    after(:each) do
      adapter.items.where(name: rand_name).delete
    end

    it 'adds new item if not present' do
      adapter.items.where(name: rand_name).delete
      covid_vend.update_item(name: rand_name, quantity: 20, price: 200)
      expect(adapter.items.where(name: rand_name).first).to include(
        name: rand_name,
        quantity: 20
      )
    end

    it 'increments the quantity by the right amount' do
      adapter.items.insert(name: rand_name, quantity: 0, price_pennies: 200)
      expect {
        covid_vend.update_item(name: rand_name, quantity: 20)
      }.to change {
        adapter.items.where(name: rand_name).first[:quantity]
      }.by(20)
    end
  end

  describe '#make_purchase' do
    let(:change1) { Change.new({'£1' => 1, '20p' => 5, '50p' => 2}) }
    after(:each) do
      adapter.items.where(name: rand_name).delete
    end

    before { covid_vend.update_item(name: rand_name, quantity: 5, price: 200) }

    it 'decrements quantity of item' do
      covid_vend.make_purchase(name: rand_name, quantity: 1, change_presented: change1)
      expect(adapter.items.where(name: rand_name).first[:quantity]).to eq(4)
    end

    it 'updates change quantities' do
      expect {
        covid_vend.make_purchase(name: rand_name, quantity: 1, change_presented: change1)
      }.to change { adapter.change.where(denomination: '20p').first[:quantity] }.by(5)
    end

    it 'returns item and change' do
      returned = covid_vend.make_purchase(name: rand_name, quantity: 1, change_presented: change1)
      expect(returned).to include(:item, :quantity, :change_returned)
    end

    it 'returns error if not enough change' do
      covid_vend.make_purchase(name: rand_name, quantity: 10, change_presented: change1)
      expect(covid_vend.make_purchase(name: 'bs_item', quantity:1, change_presented: change)).to match(/error:/)
    end

    it 'returns apology message if no availability of item' do
      expect(covid_vend.make_purchase(name: 'bs_item', quantity:1, change_presented: change1)).to match(/error:/)
    end
  end
end