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

    return versions
  end

  def min_date
    PaperTrail::Version.minimum(:created_at).to_date
  end

  private

    def valid_dates
      if from.present? && to.present? && from > to
        errors[:from] = "cannot be after To"
      end
    end

end
