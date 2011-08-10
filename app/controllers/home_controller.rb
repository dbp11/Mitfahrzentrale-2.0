class HomeController < ApplicationController
  before_filter :authenticate_user!

  # Home Controller, der uns, wenn wir Admin sind, eine Uebersicht aller Nutzer liefert
  # Wenn wir nur ein Member sind werden wir auf unsere Trips Uebersicht weitergeleitet
  def index
    if current_user.role == "admin"
      @users = User.all
      # Der Admin kann eine Liste aller User anschauen
    else
      redirect_to trips_path
      # Die Member werden weitergeleitet
    end
  end
end
