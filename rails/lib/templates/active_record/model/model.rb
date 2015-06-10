<% module_namespacing do -%>
class <%= class_name %> < <%= parent_class_name.classify %>
  # extend FriendlyId
  # friendly_id :name, use: :slugged

  #
  # Associations
  #
<% attributes.select(&:reference?).each do |attribute| -%>
  belongs_to :<%= attribute.name %><%= ', polymorphic: true' if attribute.polymorphic? %>
<% end -%>
<% if attributes.any?(&:password_digest?) -%>
  has_secure_password
<% end -%>

  #
  # Scopes
  #

  # scope :sorted, ->{ order(:name) }

  #
  # Callbacks
  #

  #
  # Validations
  #

  # validates :name,
  #           presence: true

  #
  # Class Methods
  #

  #
  # Methods
  #

  # def to_s
  #   "#{name}"
  # end
end
<% end -%>
