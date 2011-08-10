class RatingsController < ApplicationController
  before_filter :authenticate_user!
  rescue_from ActiveRecord::RecordNotFound do |exception|
    flash[:error] = "Dieser Nutzer existiert nicht!"
    redirect_to "/ratings/"+current_user.id.to_s 
  end
  
  # GET /ratings
  # GET /ratings.json
  def index
    @ratings = current_user.get_own_written_ratings
    @new_ratings = current_user.get_waiting_ratings
  end

  # GET /ratings/1
  # GET /ratings/1.json
  def show
    temp = User.find(params[:id])
	  @user = temp
    @driver_ratings = temp.get_own_driver_ratings
    @passenger_ratings = temp.get_own_passenger_ratings
    @driver_avg = temp.get_avg_rating_driver
	  @driver_cnt = temp.count_ratings_driver
    @passenger_avg = temp.get_avg_rating_passenger
  	@passenger_cnt = temp.count_ratings_passenger
  	@last_ratings = current_user.last_ratings
	  @latest_ratings = current_user.get_latest_ratings
	  if temp == current_user
		  current_user.last_ratings = Time.now
		  current_user.save
	  end

    # Zwei Arrays. eins mit den Ratings als Fahrer, eins als Mitfahrer
  end

  # GET /ratings/new
  # GET /ratings/new.json
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
      redirect_to ratings_path, notice: 'Rating was successfully created.'
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
      redirect_to @rating, notice: 'Rating was successfully updated.'
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
