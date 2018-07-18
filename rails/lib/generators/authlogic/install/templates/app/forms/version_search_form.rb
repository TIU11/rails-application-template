# frozen_string_literal: true

class VersionSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :author_id, :integer
  attribute :from, :localized_date
  attribute :to, :localized_date

  #
  # Validations
  #

  validate :valid_dates

  #
  # Methods
  #

  # Following (https://github.com/solnic/virtus/issues/307)
  def author_id=(author_id)
    @author = nil
    super
  end

  def author
    @author ||= User.friendly.find(author_id) if author_id.present?
  end

  def date_range
    (from || DateTime::Infinity)..(to || DateTime::Infinity)
  end

  def apply(versions: Activity.all)
    versions = versions.where(whodunnit: author.id) if author
    versions = versions.where('created_at >= ?', from.beginning_of_day) if from.present?
    versions = versions.where('created_at <= ?', to.end_of_day) if to.present?

    versions
  end

  def min_date
    PaperTrail::Version.minimum(:created_at)&.to_date
  end

  # Returns the value of the attribute identified by +attr_name+.
  #
  # NOTE: Expected this in +ActiveModel::AttributeMethods+, but it is only provided by
  # +ActiveRecord::AttributeMethods+ as of Rails 5.2.
  def [](attr_name)
    read_attribute_for_validation(attr_name)
  end

  private

    def valid_dates
      return unless from.present? && to.present? && from > to
      errors.add(:from, "cannot be after To")
    end

end
