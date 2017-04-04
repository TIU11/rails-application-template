class ApplicationController < ActionController::Base
  before_action :set_paper_trail_whodunnit

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Ensure authorization is everywhere (https://github.com/ryanb/cancan/wiki/Ensure-Authorization)
  check_authorization

  # Allow HTML in flash messages when flash[:html_safe] is set. Simply setting html_safe on the message won't work since JSON serialized cookies only store simple strings, not `ActiveSupport::SafeBuffer` instances. See (http://stackoverflow.com/questions/26538891/flash-message-with-html-safe-from-the-controller-in-rails-4-safe-version)
  before_action -> {
    if flash[:html_safe] # don't escape HTML when rendering flash messages
      [:success, :notice, :warning, :error].each do |f|
        flash.now[f] = flash[f].html_safe if flash[f]
      end
    end
  }

  # Handles authorization errors. Notifies user why it occurred and redirects to root_url.
  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.warn {"Access denied to '#{exception.action}' a '#{exception.subject}' was denied to #{current_user}."}

    # Notify users with detailed explanation
    if current_user
      action = I18n.translate "errors.actions.#{exception.action}", default: exception.action.to_s

      # Explain to users why they were denied access.
      roles = current_user.roles.try(:to_sentence) || 'regular user'
      if exception.subject.is_a? Class
        flash[:error] = "As a #{roles}, you are not authorized to #{action.titleize.downcase} #{exception.subject.name.pluralize.titleize}."
      else
        flash[:error] = "As a #{roles}, you are not authorized to #{action.titleize.downcase} this #{exception.subject.class.name.titleize}."
      end

      redirect_back_or_default_to root_url

    # Notify non-users without explanation
    else
      flash[:error] = "#{exception}"

      redirect_to root_url
    end
  end

  #############################################################################
  # Private Methods
  #
  private

  def store_location(path = nil)
    path ||= request.fullpath if request.get?
    return unless path.present?

    session[:return_to] = path
  end

  # Typically called to store location before showing a form to support 'Cancel' button:
  #   `before_action :store_referrer, only: [:index, :new, :edit]`
  def store_referrer
    store_location request.referer # remember where we were
  end

  def clear_location
    session[:return_to] = nil
  end

  def redirect_back_or_default_to(default)
    redirect_to params[:redirect_uri] || session[:return_to] || default
    session[:return_to] = nil
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end
  helper_method :current_user

  # Provides session to use when defining Abilities. Override's Cancancan default.
  def current_ability
    @current_ability ||= Ability.new(current_user, session)
  end

  def su_user
    return @su_user if defined?(@su_user)
    @su_user = User.find(session[:su_user]) if session[:su_user]
  end
  helper_method :su_user

  # Restricts action to authenticated sessions. Helpfully remembers target url
  # while a user logs in.
  def require_user
    unless current_user
      flash[:warning] = t('app.messages.require_user')
      redirect_to login_url(redirect_uri: request.path)
      return false
    end
  end

  def require_no_user
    if current_user
      flash[:warning] = t('app.messages.require_no_user')
      redirect_back_or_default_to root_url
      return false
    end
  end

  # Sets the filename header using a consistent name:
  #   `controller_path` + `action_name` + Time.now + request.format
  #   => "Reports Outreach Events Index 2015-10-20-1117am.xls"
  #
  # Provide a name or individual parts for custom behavior. For example, override the :index action with a more helpful :action_part.
  def set_filename(name = nil, action_part: nil, with_namespace: true)
    if name.nil?
      controller_part = with_namespace ? controller_path : controller_name
      controller_part = controller_part.parameterize.titleize # reports/outreach_events => 'Reports Outreach Events'
      action_part ||= action_name.titleize                    # index => 'Index'
      timestamp_part = Time.now.strftime('%F-%I%M%P')         # '2015-10-20-1117am'
      name = [controller_part, action_part, timestamp_part].reject(&:blank?).join(' ')
    end

    format_part = request.format.symbol                       # => 'xls'

    filename = "#{name}.#{format_part}"
    headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""
  end

end
