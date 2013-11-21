class PasswordReset
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :username, :email

  #
  # Validations
  #
  validates :username, :email,
            :presence => true
  validates :email,
            :email => true,
            :if => "email.present?"

  #
  # Methods
  #
  def persisted?
    false
  end

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
end
