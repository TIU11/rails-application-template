class UserSessionsController < ApplicationController
  skip_authorization_check
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => :destroy

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
    redirect_to login_url
  end
end
