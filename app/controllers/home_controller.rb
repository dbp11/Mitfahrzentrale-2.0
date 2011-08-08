class HomeController < ApplicationController
  before_filter :authenticate_user!
  def index
    @users = User.all
    redirect_to trips_path
  end
end
