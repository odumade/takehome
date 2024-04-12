require_relative '../payment_processor'
require 'rspec'

RSpec.describe PaymentProcessor do
  let(:csv_headers) { ['Name', 'Card Number', 'CCV', 'Zip Code', 'Expiration Date', 'Amount (in cents)', 'Card Type'] }
  let(:valid_card_amex) { 'Keeleigh Mackie,371449635398431,2215,35173,10/2025,87345,American Express' }
  let(:valid_card_mastercard) { 'Griffin Byers,5200828282828210,818,55068,11/2021,11373,Mastercard' }
  let(:valid_card_visa) { 'Adaline George,4242424242424242,015,35007,01/2030,52100,Visa' }
  let(:expired_card_row) { ['Expired Card', '1234567890123456', '123', '12345', '01/2021', '100', 'Visa'] }
  let(:valid_card_row) { ['Valid Card', '4242424242424242', '015', '35007', '01/2030', '100', 'Visa'] }

  describe ".process" do
    context "with valid payment data" do
      it "returns the number of cards that successfully processed" do
        input = [
          csv_headers,
          valid_card_amex.split(","),
          valid_card_mastercard.split(","),
          valid_card_visa.split(",")
        ]
  
        subject = PaymentProcessor.process(input)
  
        expect(subject).to eq("Total payments: 2")
      end
    end
  
    context "with only one row (headers)" do
      it "does nothing" do
        input = [csv_headers]
  
        subject = PaymentProcessor.process(input)
  
        expect(subject).to eq("Total payments: 0")
      end
    end
  
    context "with expired card" do
      it "does not process expired cards" do
        input = [
          csv_headers,
          expired_card_row,
          valid_card_row
        ]
  
        subject = PaymentProcessor.process(input)
  
        expect(subject).to eq("Total payments: 1")
      end
    end
  
    context "with cards with incorrect number of digits" do
      it "rejects cards with greater or fewer than 16 digits in its number" do
        input = [
          csv_headers,
          "Griffin Byers,5200828282828210,818,55068,11/2021,11373,Mastercard".split(","), # 16 digits
          "Griffin Byers,52120082828282821,818,55068,11/2021,11373,Mastercard".split(",") # 17 digits
        ]
      
        subject = PaymentProcessor.process(input)
      
        expect(subject).to eq("Total payments: 0")
      end
    end

    it "ensures credit card numbers are 16 digits except for American Express cards" do
      # Test with a Visa card having 16 digits
      input_visa = [
        csv_headers,
        "Griffin Byers,4242424242424242,818,55068,11/2025,11373,Visa".split(","),
      ]

      subject_visa = PaymentProcessor.process(input_visa)
      expect(subject_visa).to eq("Total payments: 1")

      # Test with a Mastercard card having 16 digits
      input_mastercard = [
        csv_headers,
        "Griffin Byers,5200828282828210,818,55068,11/2025,11373,Mastercard".split(","),
      ]

      subject_mastercard = PaymentProcessor.process(input_mastercard)
      expect(subject_mastercard).to eq("Total payments: 1")

      # Test with an American Express card having 15 digits
      input_amex = [
        csv_headers,
        "Griffin Byers,348762648908763,818,55068,11/2025,11373,AmEx".split(","),
      ]

      subject_amex = PaymentProcessor.process(input_amex)
      expect(subject_amex).to eq("Total payments: 1")
    end

  end
end
