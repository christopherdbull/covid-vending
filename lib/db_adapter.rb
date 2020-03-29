# frozen_string_literal: true
require 'sequel'

class DBAdapter
  attr_reader :client

  def initialize()
    # Test existence of DB
    raise 'DB not init-ed' unless Pathname.new('machine-db.db').exist?

    @client = Sequel.connect('sqlite://machine-db.db')
  end

  def seed_db()
    client.create_table? :change do
      String :denomination, unique: true, null: false
      Integer :quantity, null: false
    end

    client.create_table? :items do
      String :name, unique: true, null: false
      Integer :quantity, null: false
      Integer :price_pennies, null: false
    end

    change = client.from :change
    change.insert(denomination: '1p', quantity: 100)
    change.insert(denomination: '2p', quantity: 100)
    change.insert(denomination: '5p', quantity: 100)
    change.insert(denomination: '10p', quantity: 100)
    change.insert(denomination: '20p', quantity: 100)
    change.insert(denomination: '50p', quantity: 100)
    change.insert(denomination: '£1', quantity: 100)
    change.insert(denomination: '£2', quantity: 100)

    items = client.from :items
    items.insert(name: 'Toilet Roll', quantity: 2, price_pennies: 500)
    items.insert(name: 'Canned Tomatoes', quantity: 0, price_pennies: 400)
    items.insert(name: 'Sainsburys Lager', quantity: 5, price_pennies: 1)
  end

  def change
    client.from :change
  end

  def items
    client.from :items
  end
  
  def update_change(change:, pos_neg:)
    change.values.each do |key, value|
      case pos_neg
      when :pos
        self.change.where(denomination: key).update(quantity: Sequel[:quantity] + value)
      when :neg
        self.change.where(denomination: key).update(quantity: Sequel[:quantity] - value)
      end
    end
  end
end
