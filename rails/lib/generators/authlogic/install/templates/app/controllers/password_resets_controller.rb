class PasswordResetsController < ApplicationController
  before_filter :load_user_using_perishable_token, :only => [:edit, :update]
  skip_authorization_check

  def new
    @password_reset = PasswordReset.new(
      username: (current_user && current_user.username),
      email: (current_user && current_user.email)
    )
  end

  def create
    @password_reset = PasswordReset.new(params[:password_reset])

    if @password_reset.valid?
      @user = User.find_by_username_and_email(@password_reset.username, @password_reset.email)
      if @user && @user.active?
        flash[:notice] = "Instructions to reset your password have been emailed to the registered email. " +
          "Please check your email."
      elsif @user
        @password_reset.errors[:base] = "Account is inactive and cannot be used for access."
      else
        @password_reset.errors[:base] = %{
          Unable to find an account matching the username and email you provided.
          Try checking your spelling, or
          <a href="mailto:ocs-odponlinehelp@odpconsulting.net?subject=Request Help Resetting Password&body=
          I'm having trouble updating my password because I don't know the registered username and/or email. <add details>
          ">contact the help desk</a> to look up your account.
        }.html_safe
      end
    end

    if @user && @user.active?
      @user.reset_perishable_token!
      UserMailer.password_reset(@user).deliver
      redirect_to root_url
    else
      render :new
    end
  end

  def edit
  end

  def update
    @user.password = params[:user][:password]
    @user.password_confirmation = params[:user][:password_confirmation]

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
      flash[:notice] = "Password successfully updated"
      redirect_to user_path(@user)
    else
      render :edit
    end
  end

  private

  def load_user_using_perishable_token
    @user = User.find_using_perishable_token(params[:id])
    unless @user
      flash[:error] = ("We're sorry, but this is not an active reset link. " +
      "You can " +
      "<a href=\"#{new_password_reset_path}\">generate a new one</a>.").html_safe
      redirect_to root_url
    end
  end
end
