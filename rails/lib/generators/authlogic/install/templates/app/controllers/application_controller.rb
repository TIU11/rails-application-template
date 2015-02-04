class ApplicationController < ActionController::Base
  protect_from_forgery
  check_authorization # https://github.com/ryanb/cancan/wiki/Ensure-Authorization

  # Handles authorization errors. Notifies user why it occurred and redirects to root_url.
  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.warn "Access denied to '#{exception.action}' a '#{exception.subject}' was denied to #{current_user}."

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

  def store_location
    session[:return_to] = request.url
  end

  def clear_location
    session[:return_to] = nil
  end

  def redirect_back_or_default_to(default)
    redirect_to(session[:return_to] || default)
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

  def su_user
    return @su_user if defined?(@su_user)
    @su_user = User.find(session[:su_user]) if session[:su_user]
  end
  helper_method :su_user

  def require_user
    unless current_user
      store_location
      flash[:warning] = t('app.messages.require_user')
      redirect_to login_url
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

end
