# frozen_string_literal: true

# TODO: Unit Test using commented examples
# TODO: Handle multi-line Rails.logger messages
# TODO: consider prior art
# * https://github.com/danielsdeleo/teeth
# * https://github.com/wvanbergen/request-log-analyzer
# * https://www.schneems.com/2018/04/30/how-to-implement-a-ruby-hash-like-grammar-in-parslet/

class LogAnalyzer

  # See Rack::Utils::HTTP_STATUS_CODES
  RESPONSE_MESSAGE = /(?<response_message>[A-Za-z ()-]{2,57})/

  FORMATS = {
    # Rails.logger format. Defaults to Ruby's ::Logger::Formatter
    # @see (http://ruby-doc.org/stdlib-2.3.0/libdoc/logger/rdoc/Logger.html)
    # Log format: SeverityID, [DateTime #pid] SeverityLabel -- ProgName: message
    #
    # timestamp - log timestamp
    # pid - as per `cat /proc/sys/kernel/pid_max`
    # severity - one of %w[UNKNOWN FATAL ERROR WARN INFO DEBUG]
    rails_base: /^(?<severity_id>[A-Z]), \[(?<timestamp>\S+) #(?<pid>\d{1,5})\]  (?<severity>[A-Z]{1,7}) -- : (?<message>.*)$/,

    # views - time generating views (optional)
    # active_record - time performing queries (optional)
    # Examples:
    # * Completed 500 Internal Server Error in 76ms
    # * Completed 404 Not Found in 32ms
    # * Completed 302 Found in 2ms (ActiveRecord: 0.0ms)
    # * Completed 200 OK in 9ms (Views: 8.1ms | ActiveRecord: 0.0ms)
    request_completed: /^Completed (?<response_code>\d{3}) #{RESPONSE_MESSAGE.source} in (?<total_ms>\d+)ms(?: \((?<views_ms>Views: \d+\.\dms)?(?: | )?(?<active_record_ms>ActiveRecord: \d+\.\dms)\))$/o,

    # controller_name: ex. %w[UsersController Moodle::UsersController]
    # action_name: ex. %w[index show]
    # format: expecting one of Mime::EXTENSION_LOOKUP.keys
    # Examples:
    # * Processing by UserSessionsController#new as HTML
    # * Processing by Moodle::ClassesController#show as HTML
    request_processing: /^Processing by (?<controller_name>[\w:]+)#(?<action_name>[a-z_]+) as (?<format>\w+)$/,

    # Matches API log format in Moodle::Base (first line only)
    api_request: /^(?<response_code>\d{3}) #{RESPONSE_MESSAGE.source} in (?<milliseconds>\d+\.\d)ms for (?<method>[A-Z]{2,10}) '(?<uri>.*)'$/o
  }.freeze

  # Return named capture groups when applying the given expression on the value
  # ex. LogAnalyzer.captures(:rails_base)
  # name - identifier for a named expression, or an expression
  # value - string to match on
  def self.capture(name, value)
    return unless format_for(name).match(value)

    # TODO: Use MatchData#named_captures after Ruby 2.4
    $LAST_MATCH_INFO.names.zip($LAST_MATCH_INFO.captures).to_h
  end

  def self.format_for(name)
    regex = case name
            when Regexp
              name
            when String
              FORMATS[name.to_sym]
            when Symbol
              FORMATS[name]
            end
    regex || raise(ArgumentError, 'Expected a Regexp or known format name')
  end
end
