class UserSessionsController < ApplicationController
  skip_authorization_check only: [:new, :create, :destroy, :unsu]
  before_action :require_no_user, only: [:new, :create]
  before_action :require_user, except: [:new, :create]

  def new
  end

  def create
    @user_session = UserSession.new(params[:user_session])

    if @user_session.save
      flash[:notice] = I18n.t('app.messages.welcome')
      redirect_back_or_default_to root_url
    else
      render :new
    end
  end

  def destroy
    current_user_session.destroy
    flash[:notice] = I18n.t('app.messages.logout')
    clear_location # avoid trouble if user logs back in after downloading Excel, etc
    session.delete :su_user # clear saved user
    redirect_to login_url
  end

  # Switch User
  def su
    authorize! :su, UserSession
    @user = User.find params[:id]
    session[:su_user] = current_user.id # remember who we were

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
      flash[:notice] = "You have exited your switch user session, and resumed as #{previous_user}"
    else
      flash[:error] = "Sorry, we couldn't find your original user."
    end

    redirect_back_or_default_to root_url
  end

end
