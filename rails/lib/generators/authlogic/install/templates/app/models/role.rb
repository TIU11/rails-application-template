# frozen_string_literal: true

class Role
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :direct, :boolean, default: false
  attribute :assignable, :boolean, default: false

  ROLE_ATTRIBUTES = [
    { name: 'Administrator', direct: true },
    { name: 'System Administrator', direct: true }
  ].freeze

  #
  # Class Methods
  #

  class << self
    # Lookup a Role by symbol or string. Returns a Role or nil.
    # +name+ - Symbol or String to lookup. Will be normalized.
    def [](name)
      role_map[name.to_s.titleize]
    end

    def role_map
      @role_map ||= begin
        ROLE_ATTRIBUTES.map { |role_attributes| [role_attributes[:name], Role.new(role_attributes)] }.to_h
      end
    end

    # Name for all roles
    def names
      role_map.keys
    end

    def all
      role_map.values
    end

    def assignable
      @assignable ||= all.select(&:assignable)
    end

    def direct
      @direct ||= all.select(&:direct)
    end

    # Find canonical name for stuff like: "The Admin", :the_admin, "the_admin".
    # Returns nil if no corresponding role is found.
    def canonical_name(role)
      normalized_role = role.to_s.parameterize(separator: '_')
      all.find { |r| r.name.parameterize(separator: '_') == normalized_role }&.name
    end
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

  def inspect
    inspection = attributes.map do |name, value|
      "#{name}: #{value.inspect}"
    end.join(', ')
    "#<#{self.class}:#{object_id} #{inspection}>"
  end

end
