# frozen_string_literal: true
require_relative './db_adapter'

class CovidVend
  attr_reader :db_adapter

  def initialize()
    @db_adapter = DBAdapter.new
  end

  def update_change(denomination:, quantity:)
    db_adapter.change.where(denomination: denomination).update(quantity: Sequel[:quantity] + quantity)
  end

  def update_item(name:, quantity:)
    if db_adapter.items.where(name: name).any?
      db_adapter.items.where(name: name).update(quantity: Sequel[:quantity] + quantity) == 1
    else
      db_adapter.items.insert(name: name, quantity: quantity) >= 1
    end
  end

  def available_items
    db_adapter.items
  end
end
