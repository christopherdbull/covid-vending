# frozen_string_literal: true
require_relative './db_adapter'
require_relative './calculator'

class CovidVend
  attr_reader :db_adapter

  def initialize()
    @db_adapter = DBAdapter.new
  end

  def update_change(denomination:, quantity:)
    db_adapter.change.where(denomination: denomination).update(quantity: Sequel[:quantity] + quantity)
  end

  def update_item(name:, quantity:, price: nil)
    if db_adapter.items.where(name: name).any?
      db_adapter.items.where(name: name).update(quantity: Sequel[:quantity] + quantity) == 1
    else
      db_adapter.items.insert(name: name, quantity: quantity, price_pennies: price) >= 1
    end
  end

  def available_items
    db_adapter.items
  end

  def make_purchase(name:, quantity:, change_presented:)
    item = db_adapter.items.where(Sequel.lit('name = ? AND quantity >= ?', name, quantity)).first
    return "error: unable to supply item" unless item

    purchase_total = item[:price_pennies] * quantity
    calculator = Calculator.new(purchase_total: purchase_total, change_presented: change_presented)
    return "error: not enough change presented" unless calculator.enough_change_presented?

    current_quantities = db_adapter.change.all
    begin
      change_returned = calculator.change_returned(current_quantities)
    rescue UnableToBuildChangeError
      return "error: not enough change to complete purchase"
    end

    #input change 
    db_adapter.update_change(change: change_presented, pos_neg: :pos)

    #remove_change
    db_adapter.update_change(change: change_returned, pos_neg: :neg)

    #decrement stocke levels
    db_adapter.items.where(name: name).update(quantity: item[:quantity] - quantity)
    {item: item[:name], quantity: quantity, change_returned: change_returned.values.to_s}
  end
end
