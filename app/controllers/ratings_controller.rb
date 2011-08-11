class RatingsController < ApplicationController
  before_filter :authenticate_user!
  rescue_from ActiveRecord::RecordNotFound do |exception|
    flash[:alert] = "Dieser Nutzer existiert nicht!"
    redirect_to "/ratings/"+current_user.id.to_s 
  end
  # Exception, falls ein Bereich nicht existiert
  rescue_from Exception::StandardError do |exception|
    flash[:alert] = exception.message
    redirect_to "/ratings/"+current_user.id.to_s
  end
  # Exception für Standardfehler, z.B. Eingabefehler

  # GET /ratings
  # Liefert alle Ratings, wenn ich Admin bin, sonst nur meine
  def index
    if current_user.role == "admin"
      @ratings = Rating.all
    else
      @ratings = current_user.get_own_written_ratings
    end
    # Noch ausstehnde Bewertungen an die View geben
    @new_ratings = current_user.get_waiting_ratings
  end

  # GET /ratings/1
  # Eine Uebersicht ueber meine Ratings
  def show
    @user = User.find(params[:id])
    @driver_ratings = @user.get_own_driver_ratings
    @passenger_ratings = @user.get_own_passenger_ratings
    @driver_avg = @user.get_avg_rating_driver
	  @driver_cnt = @user.count_ratings_driver
    @passenger_avg = @user.get_avg_rating_passenger
  	@passenger_cnt = @user.count_ratings_passenger
  	@last_ratings = current_user.last_ratings
	  @latest_ratings = current_user.get_latest_ratings
	  if @user == current_user
		  current_user.last_ratings = Time.now
		  current_user.save
	  end
  end

  # GET /ratings/new
  def new
    usr = User.find(params[:uid])
    trp = Trip.find(params[:tid])
    if current_user.allowed_to_rate(usr, trp)
      @rating = Rating.new
      @rating.receiver = User.find(params[:uid])
	    @rating.trip = Trip.find(params[:tid])
    else
      redirect_to ratings_path, notice: "Du kannst den Nutzer nicht bewerten!"
    end
    #respond_to do |format|
      #format.html # new.html.erb
      #format.json { render json: @rating }
    #end
  end

  # GET /ratings/1/edit
  def edit
    @rating = Rating.find(params[:id])
  end

  # POST /ratings
  # POST /ratings.json
  def create
    @rating = Rating.new(params[:rating])
	  if @rating.save
      redirect_to ratings_path, notice: 'Bewertung wurde erfolgreich erstellt .'
    else
      render action: "new"
    end
  end

  # PUT /ratings/1
  # PUT /ratings/1.json
  def update
    authorize! :update, :rating
    @rating = Rating.find(params[:id])

    if @rating.update_attributes(params[:rating])
      redirect_to @rating, notice: 'Bewertung wurde erfolgreich aktualisiert.'
    else
      render action: "edit"
    end
  end

  # DELETE /ratings/1
  # DELETE /ratings/1.json
  def destroy
    authorize! :destroy, :rating
    @rating = Rating.find(params[:id])
    @rating.destroy
    redirect_to ratings_url
  end
end
