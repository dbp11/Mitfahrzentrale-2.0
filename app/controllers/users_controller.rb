class UsersController < ApplicationController
  before_filter :authenticate_user!
  # Sicherung das nur authentizierte Nutzer, die User anschauen können
  load_and_authorize_resource 
  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = "Zugriff verweigert!"
    redirect_to user_path(current_user.id)
  end
  #Exception, falls man auf einen Bereich nicht zugreifen kann
  rescue_from ActiveRecord::RecordNotFound do |exception|
    flash[:alert] = "Zugriff verweigert!"
    redirect_to user_path(current_user.id)
  end
  # Exception, falls ein Bereich nicht existiert
  rescue_from Exception::StandardError do |exception|
    flash[:alert] = exception.message
    redirect_to new_request_path
  end
  # Standard-Fehler werden hier mit einer mitgegebenen Message ausgegeben und  je nachdem gecatcht
  # Exception-Handling


  # GET /users/1
  # Liefert User mit einer bestimmten ID und gibt anderen Usern die Möglichkeit diesen zu ignorieren
  def show
    @user = User.find(params[:id])
    if params[:ignore] == "1"
      current_user.ignore(@user)
    elsif params[:ignore] == "0"
      current_user.unignore(@user)
    end
  end

  # GET /users/1/edit
  # User editieren
  def edit
    @user = User.find(params[:id])
  end


  # PUT /users/1
  # User aktualisieren
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      redirect_to @user, :notice => 'User was successfully updated.'
    else
      render :action => "edit" 
    end
  end
end
