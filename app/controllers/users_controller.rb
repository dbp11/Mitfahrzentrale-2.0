class UsersController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource 
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Zugriff verweigert!"
    redirect_to user_path(current_user.id)
  end
  rescue_from ActiveRecord::RecordNotFound do |exception|
    flash[:error] = "Zugriff verweigert!"
    redirect_to user_path(current_user.id)
  end

  def show
    @user = User.find(params[:id])
    if params[:ignore] == "1"
      puts "IGNORIEREN"
      current_user.ignore(@user)
    elsif params[:ignore] == "0"
      puts "NICHT MEHR IGNORIEREN"
      current_user.unignore(@user)
    end
  end

  #GET /users/1/edit_profil
  def edit_profil
    @user = User.find(params[:id])
  end


  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end


  # PUT /users/1
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      redirect_to @user, :notice => 'User was successfully updated.'
    else
      render :action => "edit" 
    end
  end
end
