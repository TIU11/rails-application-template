require 'rails_helper'

RSpec.describe EmailValidator, type: :validator do
  subject(:validator) { EmailValidator.new(attributes: { any: true }) }

  let(:dummy_class) {
    Class.new do
      include ActiveModel::Validations

      # NOTE: avoids ArgumentError "Class name cannot be blank."
      def self.name
        "Anonymous"
      end

      attr_accessor :email

      validates :email, email: true
    end
  }

  describe '#validate_each' do
    let(:record) { dummy_class.new }

    context 'with invalid emails' do
      let(:emails) { %w[mail @example.com example.com mail@example mail@example.c mail@example,com] << nil }

      it "rejects them" do
        emails.each_with_index do |email, index|
          record.email = email
          expect(record).not_to be_valid
          expect(record.errors.details).to eq({ email: [{ error: :invalid }] })
        end
      end
    end

    context 'with valid emails' do
      let(:emails) { %w[mail@example.com mail+test-a@example.co.uk mail@大众汽车.example.cn modèle@example.com] }

      it "accepts them" do
        emails.each do |email|
          record.email = email
          expect(record).to be_valid
        end
      end
    end
  end
end
