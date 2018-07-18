# frozen_string_literal: true

class PasswordResetsController < ApplicationController
  before_action :set_user, only: [:edit, :update]
  skip_authorization_check

  def new
    @password_reset = PasswordReset.new(email: current_user&.email)
  end

  def create
    @password_reset = PasswordReset.new(password_reset_params.to_h)

    if @password_reset.valid?
      @user = User.where('email ILIKE ?', @password_reset.email).first
      if @user
        flash[:notice] = t('app.messages.password_reset.sent_email')
      else
        support_email = User.administrators.first.full_email rescue I18n.t('app.support_email')
        @password_reset.errors[:base] << t('app.messages.password_reset.account_not_found_html', email: support_email).html_safe
      end
    end

    if @user
      if current_user == @user
        current_user_session.destroy
        flash[:alert] = I18n.t('app.messages.logout')
      end
      @user.reset_perishable_token!
      UserMailer.password_reset(@user).deliver_now
      redirect_to login_path
    else
      render :new
    end
  end

  def edit
  end

  def update
    @user.password = user_params[:password]
    @user.password_confirmation = user_params[:password_confirmation]

    @user.valid?

    # if it changed and password empty add error to user model
    @user.errors[:password] = "was not provided" if !@user.changed?

    # filter errors
    relevant_errors = @user.errors.to_hash.slice(:password, :password_confirmation)
    @user.errors.clear
    relevant_errors.each { |field, msgs|
      msgs.each { |msg|
        @user.errors[field] = msg
      }
    }

    if @user.errors.empty?
      @user.update_attribute :password, @user.password
      flash[:notice] = t('app.messages.password_reset.updated')
      redirect_to user_path(@user)
    else
      render :edit
    end
  end

  private

  # Only allow a trusted parameter "white list" through.
  def password_reset_params
    params.require(:password_reset).permit(:username, :email)
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def set_user
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      flash[:error] = t('app.messages.password_reset.inactive_link_html',
                        new_password_reset_path: new_password_reset_path.html_safe)
      flash[:html_safe] = true # don't escape HTML when rendering flash messages
      redirect_to login_path
    end
  end
end
