class RatingsController < ApplicationController
  before_filter :authenticate_user!
  # GET /ratings
  # GET /ratings.json
  def index
    temp = current_user
    @ratings = temp.get_own_written_ratings
    #Meine erstellten Ratings --> Methode

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @ratings }
    end
  end

  # GET /ratings/1
  # GET /ratings/1.json
  def show
    temp = User.find(params[:id])
	@user = temp
    @driver_ratings = temp.get_own_driver_ratings
    @passenger_ratings = temp.get_own_passenger_ratings
    @driver_avg = temp.get_avg_rating(@driver_ratings) 
    @passenger_avg = temp.get_avg_rating(@passenger_ratings)
    # Zwei Arrays. eins mit den Ratings als Fahrer, eins als Mitfahrer

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @rating }
    end
  end

  # GET /ratings/new
  # GET /ratings/new.json
  def new
    @rating = Rating.new
	  @rating.receiver = User.find(params[:uid])
	  @rating.trip = Trip.find(params[:tid])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @rating }
    end
  end

  # GET /ratings/1/edit
  def edit
    @rating = Rating.find(params[:id])
  end

  # POST /ratings
  # POST /ratings.json
  def create
    @rating = Rating.new(params[:rating])
    respond_to do |format|
	  if @rating.save
        format.html { redirect_to ratings_path, notice: 'Rating was successfully created.' }
        format.json { render json: @rating, status: :created, location: @rating }
      else
        format.html { render action: "new" }
        format.json { render json: @rating.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /ratings/1
  # PUT /ratings/1.json
  def update
    @rating = Rating.find(params[:id])

    respond_to do |format|
      if @rating.update_attributes(params[:rating])
        format.html { redirect_to @rating, notice: 'Rating was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @rating.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ratings/1
  # DELETE /ratings/1.json
  def destroy
    @rating = Rating.find(params[:id])
    @rating.destroy

    respond_to do |format|
      format.html { redirect_to ratings_url }
      format.json { head :ok }
    end
  end
end
