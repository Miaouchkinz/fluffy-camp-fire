class UsersController < ApplicationController

  def new
    if current_user
      redirect_to '/'
    else
      @user = User.new
    end
  end

  def confirm_email
    user = User.find_by_confirm_token(params[:id])
    if user
      user.email_activate
      session[:user_id] = user.id
      redirect_to_role_portal(user)
    end
  end

  def create
    unless @user = existing_user(params[:user][:email])
      @user = User.new(user_params)
      @user.role = "parent"
    else
      flash[:alert] = "This email is already in use, please use a different email"
      redirect_to signup_path
    end

    if @user.save
      UserMailer.registration_confirmation(@user).deliver
      flash[:notice] = "Thank you for creating an account. A confirmation email has been sent to the email you provided. Please click on the link to verify your account."
      redirect_to login_path
    else
      flash[:alert] = "Oops! Something went wrong, please try again."
      redirect_to signup_path
    end
  end

  def redirect_to_role_portal(user)
    if user.role == "parent"
      flash[:notice] = "Thank you for confirming your email! You can now enjoy using CampZone!"
      redirect_to parent_profile_path #LINK TO ADDRESS FORM
    elsif user.role == "counselor"
      flash[:notice] = "Thank you for confirming your email. Please set-up your account to continue"
      redirect_to counselor_settings_path
    elsif user.role == "director"
      flash[:notice] = "Thank you for confirming your email! You can now enjoy using CampZone!"
      redirect_to director_dashboard_index_path
    else
      raise "no role assigned"
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :password
    )
  end

  def existing_user(email)
    puts "the email is #{email}"
    @user = User.find_by_email(email)
  end

end
