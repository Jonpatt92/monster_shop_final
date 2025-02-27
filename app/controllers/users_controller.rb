class UsersController < ApplicationController
  before_action :require_user, only: :show
  before_action :exclude_admin, only: :show

  def show
    @user = current_user
    @address = Address.find(@user.default_address)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    address = @user.addresses.new(address_params)

    if @user.save && address.save
      @user.assign_address(address.id)
      session[:user_id] = @user.id
      flash[:notice] = "Welcome, #{@user.name}!"
      redirect_to profile_path
    else
      flash.now[:error] = @user.errors.full_messages.to_sentence.gsub("Addresses", '')
      render :new
    end
  end

  def edit
    @user = current_user
    if request.env['PATH_INFO'] == "/profile/edit/password"
      @password_change = true
    else
      @password_change = false
    end
  end

  def update
    @user = current_user
    if params[:address_id]
      assign_default
    else
      @user.update(user_params)
      if @user.save
        update_flash(@user)
        redirect_to "/profile"
      else
        flash[:error] = @user.errors.full_messages.to_sentence
        redirect_to "/profile/edit" if !user_params[:password_confirmation]
        redirect_to "/profile/edit/password" if user_params[:password_confirmation]
      end
    end
  end

  def assign_default
    user = current_user
    address = Address.find(params[:address_id])

    if user.assign_address(params[:address_id])
      flash[:success] = "You have set '#{address.nickname}' as your default address"
      redirect_to profile_path
    end
  end

  def update_flash(user)
    flash[:sucess] = "Hello, #{user.name}! You have successfully updated your profile." if !user_params[:password_confirmation]
    flash[:sucess] = "Hello, #{user.name}! You have successfully updated your password." if user_params[:password_confirmation]
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :default_address)
  end

  def address_params
    params.require(:address).permit(:street_address, :city, :state, :zip, :nickname)
  end
end
