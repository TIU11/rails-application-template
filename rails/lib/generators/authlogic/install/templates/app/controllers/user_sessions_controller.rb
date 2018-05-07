# frozen_string_literal: true

class UserSessionsController < ApplicationController
  skip_authorization_check only: [:new, :create, :destroy, :unsu, :seconds_remaining, :timeout, :continue]
  before_action :require_no_user, only: [:new, :create]
  before_action :require_user, except: [:new, :create, :seconds_remaining, :timeout, :continue, :destroy]

  def new
    @user_session = UserSession.new
    session.delete :su_user
  end

  def create
    @user_session = UserSession.new(user_session_params.to_h)
    session.delete :su_user

    if @user_session.save
      flash[:notice] = I18n.t('app.messages.welcome')
      redirect_back_or_default_to root_url
    else
      render :new
    end
  end

  def destroy
    current_user_session&.destroy
    flash[:notice] = if _timeout < Time.now
                       I18n.t('app.messages.timeout') # logout due to timeout
                     else
                       I18n.t('app.messages.logout') # manual logout
                     end

    clear_location # avoid trouble if user logs back in after downloading Excel, etc
    session.delete :su_user # clear saved user
    redirect_to login_url(params.permit!.slice(:redirect_uri)) # TODO: sanitize instead of permit!
  end

  # Switch User
  def su
    authorize! :su, UserSession
    @user = User.friendly.find params[:id]
    session[:su_user] = current_user.id # remember who we were
    store_referrer # remember where we were

    current_user_session.destroy
    UserSession.create!(@user)
    flash[:notice] = "You've been logged in as #{@user}"

    redirect_back_or_default_to user_path(@user)
  end

  # Un-switch User
  def unsu
    if session.key?(:su_user)
      previous_user = User.find session[:su_user]
      UserSession.create! previous_user
      session.delete :su_user
      store_referrer # remember where we were
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
    !action_name.in? %w[seconds_remaining timeout]
  end

  private

    def user_session_params
      params.require(:user_session).permit(:username, :password)
    end

    def _timeout
      if current_user
        current_user.last_request_at + User.logged_in_timeout.seconds
      else
        15.minutes.ago # an arbitrary, clearly-past time, as the session has expired
      end
    end
end
