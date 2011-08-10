class HomeController < ApplicationController
  before_filter :authenticate_user!

  def index
    if current_user.role == "admin"
      @users = User.all
    else
      redirect_to trips_path
    end
  end
end
