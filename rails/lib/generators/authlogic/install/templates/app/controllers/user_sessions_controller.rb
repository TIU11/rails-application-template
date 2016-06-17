class UserSessionsController < ApplicationController
  skip_authorization_check only: [:new, :create, :destroy, :unsu, :seconds_remaining, :timeout, :continue]
  before_action :require_no_user, only: [:new, :create]
  before_action :require_user, except: [:new, :create, :seconds_remaining, :timeout, :continue, :destroy]

  def new
    @user_session = UserSession.new
    session.delete :su_user
  end

  def create
    @user_session = UserSession.new(params[:user_session])
    session.delete :su_user

    if @user_session.save
      flash[:notice] = I18n.t('app.messages.welcome')
      redirect_back_or_default_to root_url
    else
      render :new
    end
  end

  def destroy
    current_user_session.destroy if current_user_session
    if (_timeout < Time.now) # logout due to timeout
      flash[:notice] = I18n.t('app.messages.timeout')
    else # manual logout
      flash[:notice] = I18n.t('app.messages.logout')
    end

    clear_location # avoid trouble if user logs back in after downloading Excel, etc
    session.delete :su_user # clear saved user
    redirect_to login_url(params.slice(:redirect_uri))
  end

  # Switch User
  def su
    authorize! :su, UserSession
    @user = User.friendly.find params[:id]
    session[:su_user] = current_user.id # remember who we were
    store_location request.referer # remember where we were

    current_user_session.destroy
    UserSession.create!(@user)
    flash[:notice] = "You've been logged in as #{@user}"

    redirect_back_or_default_to user_path(@user)
  end

  # Un-switch User
  def unsu
    if session.has_key?(:su_user)
      previous_user = User.find session[:su_user]
      UserSession.create! previous_user
      session.delete :su_user
      store_location request.referer # remember where we were
      flash[:notice] = "You have exited your switch user session, and resumed as #{previous_user}"
    else
      flash[:error] = "Sorry, we couldn't find your original user."
    end

    redirect_back_or_default_to root_url
  end

  # Returns seconds until session timeout
  def seconds_remaining
    render plain: (_timeout - Time.now)
  end

  # Returns timeout in ISO 8601 date format, which is compatible with JavaScript's `Date.parse(string)` method.
  def timeout
    render plain: _timeout.iso8601
  end

  # A "keep-alive" request to keep the current user session from timing out.
  def continue
    render plain: _timeout.iso8601
  end

  # Tell Authlogic not to update last_request_at for :seconds_remaining requests
  def last_request_update_allowed?
    not action_name.in? ['seconds_remaining', 'timeout']
  end

  private

    def _timeout
      if current_user
        current_user.last_request_at + User.logged_in_timeout.seconds
      else
        15.minutes.ago # an arbitrary, clearly-past time, as the session has expired
      end
    end
end
