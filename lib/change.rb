class Change
  CHANGE_VALUES = {
    '1p' => 1,
    '2p' => 2,
    '5p' => 5,
    '10p' => 10,
    '20p' => 20,
    '50p' => 50,
    '£1' => 100,
    '£2' => 200
  }

  attr_reader :values

  def initialize(args = {})
    @values = format_change(args)
  end

  def add_coin(denomination)
    return unless CHANGE_VALUES.keys.include?(denomination)
    @values[denomination] = @values[denomination] ? @values[denomination] + 1 : 1
  end

  def total
    values.reduce(0) do |acc, (key, value)|
      acc + CHANGE_VALUES[key] * value
    end
  end

  private
  def format_change(change_hash)
    change_hash.delete_if do |key, _value|
      !CHANGE_VALUES.keys.include?(key)
    end.compact
  end
end