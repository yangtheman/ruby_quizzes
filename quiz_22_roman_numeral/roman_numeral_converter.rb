#!/Users/yangtheman/.rvm/rubies/ruby-2.1.2/bin/ruby

module ConversionReference
  def numeral_to_number
    {
      "I" => 1,
      "V" => 5,
      "X" => 10,
      "L" => 50,
      "C" => 100,
      "D" => 500,
      "M" => 1000
    }
  end

  def number_to_numeral
    numeral_to_number.invert
  end
end

class Converter

  attr_reader :input

  def initialize(input)
    @input = input
    @base_object = base_object
  end

  def convert
    @base_object.convert
  end

  private

  def base_object
    input.to_s =~ /^[\d]+$/ ? DecimalNumber.new(input) : RomanNumeral.new(input)
  end

end


class DecimalNumber
  include ::ConversionReference

  attr_reader :number_str

  def initialize(number)
    @number_str = number.to_s
  end

  def convert
    converted = ''
    number_str.split('').each_with_index do |digit, index|
      decimal_place = 10 ** (number_str.length - index - 1)

      next_str = case digit.to_i
      when 1..3 then number_to_numeral[decimal_place]*digit.to_i
      when 4 then number_to_numeral[decimal_place] + number_to_numeral[decimal_place*5]
      when 5 then number_to_numeral[decimal_place*5]
      when 6..8 then number_to_numeral[decimal_place*5] + number_to_numeral[decimal_place]*(digit.to_i-5)
      when 9 then number_to_numeral[decimal_place] + number_to_numeral[decimal_place*10]
      else
        ''
      end

      converted += next_str
    end
    converted
  end
end

class RomanNumeral
  include ::ConversionReference

  attr_reader :numeral_str

  def initialize(numeral)
    @numeral_str = numeral
  end

  def convert
    converted = 0
    index = 0
    numeral_array = numeral_str.split('')
    while index < numeral_array.length
      number = numeral_to_number[numeral_array[index]]
      next_number = numeral_to_number[numeral_array[index+1]]
      if next_number && next_number > number
        converted += (next_number - number)
        index += 2
      else
        converted += number
        index += 1
      end
    end
    converted
  end
end
