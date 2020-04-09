# frozen_string_literal: true

module AnalyticsHelper

  # Generates Google Analytics url
  #
  # Usage: analytics_url utmac: 'UA-00000000-0',
  #       utm_campaign: 'technical_contact_reservation_notification',
  #       utm_source:   'org:' + @users.first.organization.abbreviation
  #
  # Options:
  #   utmac         Account String. Appears on all requests.
  #   utm_campaign  Campaign Name
  #   utm_source    Campaign Source
  #   utm_medium    Campaign Medium
  #   utmp          Page request of the current page.
  #   utmn          Unique ID generated for each GIF request to prevent caching of the GIF image.
  #   utmwv         Tracking code version
  #   utmcc         Cookie
  #
  # Option Documentation:
  #   https://developers.google.com/analytics/resources/articles/gaTrackingTroubleshooting#gifParameters
  #
  # TODO: default utmac: ENV['GOOGLE_ANALYTICS']
  def analytics_url(options = {})
    logger.warn "Missing ENV['GOOGLE_ANALYTICS']" if ENV['GOOGLE_ANALYTICS'].blank?

    # Apply default options
    options.reverse_merge!(
      utmac: ENV['GOOGLE_ANALYTICS'],
      utmn: Random.rand(1_000_000_000..9_999_999_999),
      utmr: request&.url || '-',
      utmwv: '5.3.0d',
      utm_medium: 'email',
      utmp: '/default-analytics-page'
    )
    options[:utmp] = options[:utm_campaign] if options[:utm_campaign]
    options[:utmcc] = generate_cookie(options.slice(:utm_campaign, :utm_medium))

    # Build URL
    'https://www.google-analytics.com/__utm.gif?' + options.to_query
  end

  # Generate Google Analytics tracking image.
  def analytics_image_tag(options = {})
    image_tag analytics_url(options), width: 1, height: 1
  end

  private

    # Generate Google Analytics utmcc cookie
    # For structure, see http://blog.vkistudios.com/index.cfm/2010/8/31/GA-Basics-The-Structure-of-Cookie-Values
    def generate_cookie(utm_campaign: '(direct)', utm_medium: '(none)')
      session_num = 2
      campaign_num = 2

      subcookies = [
        "__utma=#{domain_id}.#{visitor_id}.#{initial_visit}.#{previous_session}.#{current_session}.2",
        "__utmb=#{domain_id}",
        "__utmc=#{domain_id}",
        "__utmz=#{domain_id}.#{timestamp}.#{session_num}.#{campaign_num}."\
          "utmccn=#{utm_campaign}|utmcsr=(direct)|utmcmd=#{utm_medium}"
      ]
      subcookies.join ";+"
    end

    # "Domain Hash" used by all cookies from this domain.
    # TODO: so, should it *not* be random, but site-specific?
    def domain_id
      Random.rand(10_000_000..99_999_999) # random cookie number
    end

    # A random unique ID
    # TODO: should this only be unique per session? or perhaps it already is?
    def visitor_id
      Random.rand(1_000_000_000..2_147_483_647) # number under 2147483647
    end

    # Timestamp for the initial visit
    def timestamp
      Time.current.strftime('%s')
    end

    alias initial_visit timestamp
    alias previous_session timestamp
    alias current_session timestamp

end
