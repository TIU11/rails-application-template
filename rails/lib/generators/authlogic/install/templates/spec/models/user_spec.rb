require 'rails_helper'

RSpec.describe User, type: :model do
  user = FactoryBot.build(:user)

  it "should have a name and email" do
    expect(user.name).to eq('George Burdell')
    expect(user.first_initial).to eq('G')
    expect(user.full_email).to eq(%("George Burdell" <g.p.burdell@example.com>))
  end

  it "should get a username and password before validation" do
    user = FactoryBot.build(:user, password: nil, password_confirmation: nil)
    expect(user.password).to be_nil
    expect(user.username).to be_nil
    user.validate
    expect(user.password).to_not be_nil
    expect(user.username).to eq('gburdell')
  end

  it "should validate that emails look like emails" do
    invalid_emails = ['foo', 'foo@example', 'example.com', ' foo@example.com ']
    invalid_emails.each do |email|
      user.email = email
      expect(user).to_not be_valid
      expect(user.errors[:email]).to contain_exactly "should look like an email address."
    end
  end
end
