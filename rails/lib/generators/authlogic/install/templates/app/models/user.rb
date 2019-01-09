# frozen_string_literal: true

class User < ApplicationRecord
  include FriendlyId
  friendly_id :username_candidates, use: :slugged, slug_column: :username

  enum status: [:active, :inactive]
  attribute :direct_roles, :role, array: true
  alias_attribute :roles, :direct_roles

  acts_as_authentic do |config|
    config.perishable_token_valid_for 1.day # for password reset email
    config.logged_in_timeout 1.hours
    config.validate_email_field true
  end

  has_paper_trail(
    ignore: [
      :updated_at
    ],
    skip: [
      :perishable_token,
      :last_request_at,
      :current_login_at,
      :last_login_at,
      :current_login_ip,
      :last_login_ip
    ]
  )

  #
  # Scopes
  #

  scope :sorted, -> { order(:first_name, :last_name) }
  scope :has_role, ->(role) { # returns users with direct roles (doesn't include team-assignment-derived roles)
    where('? = any(users.direct_roles)', Role.canonical_name(role))
  }
  scope :administrators, -> { has_role(:administrator) }

  #
  # Callbacks
  #

  before_validation :clean_roles
  before_validation :ensure_new_account_has_password

  #
  # Validations
  #

  validates :first_name, :last_name, presence: true
  validates :password,
            confirmation: { if: :require_password? }, length: { minimum: 8, if: :require_password? }
  validates :email,
            length: { maximum: 100 }, format: { with: /.@./ },
            uniqueness: { case_sensitive: false, if: :will_save_change_to_email? }
  validate :role_must_be_in_list

  #
  # Class Methods
  #

  def self.find_by_username_or_email(value = nil)
    where(username: value).or(where(email: value)).first
  end

  #
  # Methods
  #

  # Examples:
  # - is? :program_administrator, "Building Coach", :admin
  # => true if user has any of these roles
  def is?(*role)
    role.any? { |r| Role[r].in? roles }
  end

  def name
    [first_name, last_name].reject(&:blank?).join(' ')
  end

  def first_initial
    first_name&.first
  end

  def full_email
    %("#{name}" <#{email}>) if email.present?
  end

  def to_s
    name || email
  end

  private

    # Assign user a default password
    def ensure_new_account_has_password
      return unless password.nil? && new_record?
      Rails.logger.debug { "Generating random password for #{email}" }
      random_password = SecureRandom.urlsafe_base64(12)
      self.password = random_password
      self.password_confirmation = random_password
    end

    def username_candidates
      [
        [first_initial, last_name].join,
        [first_name, last_name].join,
        :email
      ]
    end

    def clean_roles
      roles.reject!(&:blank?)
    end

    def role_must_be_in_list
      invalid_roles = roles - Role.direct
      invalid_roles.each do |role|
        errors.add(:roles, "'#{role}' is not a recognized role")
      end
    end

end
