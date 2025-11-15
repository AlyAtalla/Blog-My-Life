require 'fileutils'

class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: 'Account created and logged in.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = current_user
    redirect_to root_path, alert: 'Not signed in' unless @user
  end

  def update
    @user = current_user
    unless @user
      redirect_to root_path, alert: 'Not signed in' and return
    end

    # handle avatar upload
    if params[:user] && params[:user][:avatar]
      uploaded = params[:user][:avatar]
      filename = "user_#{@user.id}_avatar#{File.extname(uploaded.original_filename)}"
      dir = Rails.root.join('public', 'uploads', 'avatars')
      FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
      path = dir.join(filename)
      File.open(path, 'wb') { |f| f.write(uploaded.read) }
      @user.avatar_url = "/uploads/avatars/#{filename}"
    end

    if @user.update(user_update_params)
      redirect_to profile_path, notice: 'Profile updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def user_update_params
    params.require(:user).permit(:name, :email, :bio)
  end
end
