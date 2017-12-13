class VersionSearchForm
  include ActiveModel::Model
  include Virtus.model

  attribute :author_id, Integer
  attribute :from, Date
  attribute :to, Date

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

  def from=(value)
    super coerce_date(value)
  end

  def to=(value)
    super coerce_date(value)
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
    PaperTrail::Version.minimum(:created_at).to_date
  end

  private

    def valid_dates
      return unless from.present? && to.present? && from > to
      errors.add(:from, "cannot be after To")
    end

    def coerce_date(value)
      return if value.empty?
      Date.strptime(value, I18n.translate("date.formats.default")) rescue nil
    end

end
