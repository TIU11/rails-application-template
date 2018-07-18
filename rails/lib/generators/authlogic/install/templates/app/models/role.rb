# frozen_string_literal: true

class Role
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string

  ROLES = [
    { name: 'Administrator' },
    { name: 'System Administrator' }
  ].freeze

  #
  # Class Methods
  #

  def self.all
    @roles ||= ROLES.map { |role_attributes| Role.new role_attributes }
  end


  # Find canonical name for stuff like: "The Admin", :the_admin, "the_admin".
  # Returns nil if no corresponding role is found.
  def self.canonical_name(role)
    normalized_role = role.to_s.parameterize(separator: '_')
    all.find { |r|
      r.name.parameterize(separator: '_') == normalized_role
    }.try(:name)
  end

  #
  # Methods
  #

  def to_sym
    name.parameterize(separator: '_').to_sym
  end

  def to_s
    name
  end

end
