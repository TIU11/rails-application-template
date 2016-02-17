class PaperTrail::Version < ActiveRecord::Base
  include PaperTrail::VersionConcern # what is this for?

  scope :sorted, -> { reorder(created_at: :desc) }
  scope :recent, -> { sorted.first(3) }

  # Get User when whodunnit is an id, otherwise return the raw string.
  # e.g.
  # => #<User: id: 1, email: 'ahoyt@tiu11.org'...>
  # => 'ahoyt: console'
  # => 'ahoyt: rake db:import:users'
  # => 'Anonymous'
  def who
    user_id = whodunnit.to_i
    if user_id > 0
      User.find(user_id)
    else
      whodunnit || 'Anonymous'
    end
  end

end
