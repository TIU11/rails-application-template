require 'rails_helper'

RSpec.describe EmailValidator, type: :validator do
  subject(:validator) { EmailValidator.new(attributes: { any: true }) }

  describe '#validate_each' do
    let(:errors) { ActiveModel::Errors.new(OpenStruct.new) }
    let(:record) { instance_double(ActiveModel::Validations, errors: errors) }

    context 'with invalid emails' do
      let(:emails) { %w[mail @example.com example.com mail@example mail@example.c mail@example,com] << nil }

      it "rejects them" do
        emails.each_with_index do |email, index|
          validator.validate_each(record, :email, email)
          expect(record.errors.count).to eq index + 1
        end
      end
    end

    context 'with valid emails' do
      let(:emails) { %w[mail@example.com mail+test-a@example.co.uk mail@大众汽车.example.cn modèle@example.com] }

      it "accepts them" do
        emails.each do |email|
          validator.validate_each(record, :email, email)
          expect(record.errors.any?).to be false
        end
      end
    end
  end
end
