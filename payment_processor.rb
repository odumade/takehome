require "csv"
require 'fileutils'


class CardProcessor
  def initialize(card_number, ccv, owner_name, expiration_date, zip_code, amount, card_type)
    @card_number = card_number
    @ccv = ccv
    @owner_name = owner_name
    @expiration_date =  expiration_date
    @zip_code = zip_code
    @amount = amount
    @card_type = card_type
  end

  def card_expired?
    month,year = @expiration_date.split("/").map(&:to_i)

    return true if Time.now.year > year.to_i
    if Time.now.year == year
      Time.now.month <= month
    else
      false
    end
  end

  # In this exercise we can assume that if everything is otherwise valid the
  # payment will process successfully
  def process!
    true
  end
end

class PaymentProcessor
  
  def self.process(input)
    @input = input

    @processed_cards = []

    cards_to_try.each do |card|
      processor = CardProcessor.new(
        card[1], card[2], card[0], card[4], card[3], card[5], card[6]
      )
      next if processor.card_expired?
      @processed_cards << processor.process!
    end

    report
  end

  def self.report
    "Total payments: #{total_payments}"
  end

  def self.cards_to_try
    @input[1..-1]
  end

  def self.total_payments
    @processed_cards.count { |status| status == true }
  end

  def self.total_dollar_amount(input)
    @input = input
    total_amount = 0
    cards_to_try.each do |card|
      total_amount += card[5].to_i
    end
    total_amount
  end

  def self.total_dollar_amounts_by_card_type(input)
    @input = input
    total_amounts_by_card_type = Hash.new(0)

    cards_to_try.each do |card|
      card_type = card[6]
      amount = card[5].to_i
      total_amounts_by_card_type[card_type] += amount
    end

    total_amounts_by_card_type
  end

  def self.copy_and_rename_csv_file_with_timestamp
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    old_file_path = File.expand_path("./payments.csv", File.dirname(__FILE__))
    new_file_path = File.expand_path("./#{timestamp}_payments.csv", File.dirname(__FILE__))
    FileUtils.copy(old_file_path, new_file_path)
    new_file_path
  end

end

file_path = File.expand_path("./payments.csv", File.dirname(__FILE__))
puts "Total payments: #{PaymentProcessor.process CSV.read(file_path)}"

puts "Total dollar amount of payments processed: $#{PaymentProcessor.total_dollar_amount(CSV.read(file_path))/100.0}"

total_amounts_by_card_type = PaymentProcessor.total_dollar_amounts_by_card_type(CSV.read(file_path))
puts "Total dollar amounts of payments categorized by card type:"
total_amounts_by_card_type.each do |card_type, total_amount|
  puts "#{card_type}: $#{total_amount/100.0}"
end

new_file_path = PaymentProcessor.copy_and_rename_csv_file_with_timestamp
puts "Copied and renamed payment.csv to: #{new_file_path}"