# frozen_string_literal: true

class PasswordReset
  include ActiveModel::Model
  include Virtus.model

  attribute :username, String
  attribute :email, String

  #
  # Validations
  #

  validates :email,
            presence: true
  validates :email,
            email: true, allow_blank: true

  #
  # Methods
  #

  def persisted?
    false
  end
end
