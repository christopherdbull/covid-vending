# frozen_string_literal: true
require_relative './change'

class Calculator
  attr_reader :change_presented, :purchase_total

  def initialize(purchase_total:, change_presented:)
    @change_presented = change_presented
    @purchase_total = purchase_total
  end

  def enough_change_presented?
    change_presented.total >= purchase_total
  end

  def change_returned(current_change)
    return Change.new if difference == 0
    build_change(current_change)
  end

  private

  def build_change(current)
    difference = self.difference
    change = Change.new
    available_change = current.map {|c| c.merge({value: Change::CHANGE_VALUES[c[:denomination]]})}
    available_change = available_change.sort { |a,b| b[:value] <=> a[:value] }
    until difference == 0 do
      #find largest available coin < difference
      coin = available_change.detect do |c|
        c[:value] <= difference && c[:quantity] > 0
      end
      raise UnableToBuildChangeError unless coin
      # add to change
      change.add_coin(coin[:denomination])
      # subtract from difference
      difference -= coin[:value]
    end
    return change
  end

  def difference
    change_presented.total - purchase_total
  end
end

class UnableToBuildChangeError < StandardError; end