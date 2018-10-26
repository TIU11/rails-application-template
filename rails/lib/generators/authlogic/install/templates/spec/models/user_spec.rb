require 'rails_helper'

RSpec.describe User, type: :model do
  user = FactoryBot.build(:user)

  it "has a name and email" do
    expect(user.name).to eq('George P Burdell')
    expect(user.first_initial).to eq('G')
    expect(user.full_email).to match(/"George P Burdell" <g.p.burdell-\d+@example.com>/)
  end

  it "gets a username and password before validation" do
    user = FactoryBot.build(:user, password: nil, password_confirmation: nil)
    expect(user.password).to be_nil
    expect(user.username).to be_nil
    user.validate
    expect(user.password).not_to be_nil
    expect(user.username).to eq('gburdell')
  end

  it "validates that emails look like emails" do
    invalid_emails = ['foo', 'foo@example', 'example.com']
    invalid_emails.each do |email|
      user.email = email
      expect(user).not_to be_valid
      expect(user.errors[:email]).to contain_exactly "should look like an email address."
    end
  end

end
