# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Type::Role, type: :model do

  # Define a test model. Subclass of self to namespace within this test.
  class self::ModelForType
    include ActiveModel::Model
    include ActiveModel::Attributes
    attribute :role, :role
  end

  it "should cast user input for role to a Role" do
    valid_roles = [:contact, 'Contact', 'CONTACT']
    valid_roles.each do |role|
      model = self.class::ModelForType.new(role: role)
      expect(model.role).to be_a(Role)
    end
  end

  it "should cast input in where statements" do
    sql = User.where(roles: [:contact]).to_sql
    expected_sql = %(SELECT "users".* FROM "users" WHERE "users"."direct_roles" = '{Contact}')
    expect(sql).to eql(expected_sql)
  end
end
