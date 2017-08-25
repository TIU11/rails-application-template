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
  def analytics_url(options = {})
    return unless options[:utmac]
    # Setup default options
    @options = options.merge(utmn:       Random.rand(1_000_000_000..9_999_999_999),
                             utmwv:      '5.3.0d',
                             utm_medium: 'email',
                             utmp:       '/default-analytics-page')
    @options[:utmr] = request&.url || '-'
    @options[:utmp] = options[:utm_campaign] if options[:utm_campaign]
    @options[:utmcc] = generate_cookie(@options)

    # Override defaults with provided options
    @options.merge!(options)

    # Build URL
    'http://www.google-analytics.com/__utm.gif?' + @options.to_query
  end

  # Generate Google Analytics tracking image.
  def analytics_image_tag(options = {})
    "<img src=\"#{analytics_url(options)}\" width=\"1\" height=\"1\" />".html_safe
  end

  private

  # Generate Google Analytics utmcc cookie
  # For structure, see http://blog.vkistudios.com/index.cfm/2010/8/31/GA-Basics-The-Structure-of-Cookie-Values
  def generate_cookie(options = {})
    cookie_num = Random.rand(10_000_000..99_999_999) # random cookie number
    random_num = Random.rand(1_000_000_000..2_147_483_647) # number under 2147483647
    today = Time.now.strftime('%s')
    session_num = 2
    campaign_num = 2
    utmccn = options[:utm_campaign] || '(direct)' # campaign
    utmcmd = options[:utm_medium] || '(none)' # medium

    subcookies = [
      "__utma=#{cookie_num}.#{random_num}.#{today}.#{today}.#{today}.2",
      "__utmb=#{cookie_num}",
      "__utmc=#{cookie_num}",
      "__utmz=#{cookie_num}.#{today}.#{session_num}.#{campaign_num}.utmccn=#{utmccn}|utmcsr=(direct)|utmcmd=#{utmcmd}"
    ]
    subcookies.join ";+"
  end

end
