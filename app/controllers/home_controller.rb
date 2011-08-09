class HomeController < ApplicationController
  before_filter :authenticate_user!

  #########################home_controller#####################################

  #Wenn ich Admin bin bekomme ich eine Liste aller User, andernfalls Weiterleitung zu meinen Trips
  def index
    if current_user.role == "admin"
      @users = User.all
    else
      redirect_to trips_path
    end
  end
end
