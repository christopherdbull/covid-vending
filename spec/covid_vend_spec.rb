require 'covid_vend'
require 'db_adapter'
require 'securerandom'

RSpec.describe(CovidVend) do
  let(:adapter) { DBAdapter.new }
  let(:covid_vend) { CovidVend.new }

  describe "update_change" do
    it 'increments the quantity by the right amount' do
      expect {
        covid_vend.update_change(denomination: '£1', quantity: 20)
      }.to change {
        adapter.change.where(denomination: '£1').first[:quantity]
      }.by(20)
    end
  end

  describe "update_item" do
    let(:rand_name) { SecureRandom.hex(4) }

    after(:each) do
      adapter.items.where(name: rand_name).delete
    end

    it 'adds new item if not present' do
      adapter.items.where(name: rand_name).delete
      covid_vend.update_item(name: rand_name, quantity: 20)
      expect(adapter.items.where(name: rand_name).first).to eq({
        name: rand_name,
        quantity: 20
      })
    end

    it 'increments the quantity by the right amount' do
      adapter.items.insert(name: rand_name, quantity: 0)
      expect {
        covid_vend.update_item(name: rand_name, quantity: 20)
      }.to change {
        adapter.items.where(name: rand_name).first[:quantity]
      }.by(20)
    end
  end
end