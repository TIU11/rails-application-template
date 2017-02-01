class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Select one or more random records from the database
  # Ex. "The winners are #{User.sample(3).to_sentence}!"
  def self.sample(sample_size = 1)
    case ActiveRecord::Base.connection.adapter_name
    when 'PostgreSQL', 'SQLite'
      limit(sample_size).order('RANDOM()')
    when 'MySQL'
      limit(sample_size).order('RAND()')
    else
      # Here are more http://stackoverflow.com/questions/19412/how-to-request-a-random-row-in-sql
      raise 'Current database adapter is not supported.'
    end
  end
end
