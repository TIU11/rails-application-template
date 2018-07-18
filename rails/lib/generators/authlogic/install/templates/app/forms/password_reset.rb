# frozen_string_literal: true

class PasswordReset
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :username, :string
  attribute :email, :string

  #
  # Validations
  #

  validates :email, presence: true
  validates :email, email: true, allow_blank: true
end
