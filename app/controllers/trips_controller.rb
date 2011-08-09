class TripsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource 
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Zugriff verweigert!"
    redirect_to trips_path
  end
  rescue_from ActiveRecord::RecordNotFound do |exception|
    flash[:error] = "Zugriff verweigert!"
    redirect_to trips_path
  end
  
  # GET /trips
  # GET /trips.json
  def check (trp)
    @trip = trp
    @FAHRER = 0
    @MITFAHRER = 1
    @POTENTIELLER_MITFAHRER = 2
    @GAST = 3
    @user = current_user
    if current_user == @trip.user
      flash[:notice] = "FAHRER"
      @status = @FAHRER
    elsif @trip.user_committed (current_user)
      flash[:notice] = "MITFAHRER"
      @status = @MITFAHRER
    elsif @trip.user_uncommitted (current_user)
      flash[:notice] = "POTENTIELLER_MITFAHRER"
      @status = @POTENTIELLER_MITFAHRER
    else
      flash[:notice] = "GAST"
      @status = @GAST
    end
    return @status
  end

  def index
    #Dummy. Wird entfernt
    temp = current_user
    @trips = temp.driven
    #Alle Fahrten, die ich als Fahrer noch absolvieren muss
    @future_trips = temp.to_drive
    #Alle Fahrten, die ich als Fahrer absolviert habe
    @completed_trips = temp.driven
    #Alle Fahrten, die ich als Mitfahrer absolviert habe
    @ridden_trips = temp.driven_with
    #Alle Fahrten, in denen ich Mitfahrer noch teilnehmen
    @future_ridden_trips = temp.to_drive_with
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @trips }
    end
  end

  # GET /trips/1
  # GET /trips/1.json
  def show
    @FAHRER = 0
    @MITFAHRER = 1
    @POTENTIELLER_MITFAHRER = 2
    @GAST = 3
    @user = current_user
    @trip = Trip.find(params[:id])

    @status = check(@trip)
    @free_seats = @trip.get_free_seats
    @occupied_seats = @trip.get_occupied_seats
    puts "stirb"
    if params[:request]
      if current_user.bewerben(@trip)
        puts "HIER"
        tmp = Message.new()
        tmp.writer = User.find(@trip.user_id)
        tmp.receiver = current_user
        tmp.subject = "[[/trips/"+@trip.id.to_s+"|"+@trip.start_city+" - "+@trip.end_city+"]]"
        tmp.message = "Ihre Bewerbung fuer den Trip von "+@trip.start_city+" nach "+@trip.end_city+" war erfolgreich. <3"        
        tmp.delete_writer = true
        tmp.delete_receiver = false
        puts tmp.to_s
        tmp.save
        tmp = Message.new()
        tmp.writer = current_user 
        tmp.receiver = User.find(@trip.user_id)
        tmp.subject = "[[/trips/"+@trip.id.to_s+"|"+@trip.start_city+" - "+@trip.end_city+"]]"
        tmp.message = "Bewerbung fuer den Trip von "+@trip.start_city+" nach "+@trip.end_city+".\n Nutzer annehmen: [[/trips/"+@trip.id.to_s+"?accept=true&uid="+current_user.id.to_s+"|Hier!]]"        

        tmp.delete_writer = true
        tmp.delete_receiver = false
        tmp.save
        end
    end

    if params[:accept] and @status == @FAHRER
      temp = User.find(params[:uid])
      if @trip.accept(temp)  
        tmp = Message.new()
        tmp.writer = current_user
        tmp.receiver = temp
        tmp.message = "Sie wurden fuer den Trip von "+@trip.start_city+" nach "+@trip.end_city+" angenommen!!"
        tmp.subject = "[[/trips/"+@trip.id.to_s+"|"+@trip.start_city+" - "+@trip.end_city+"]]"
        tmp.delete_writer = true
        tmp.delete_receiver = false
        tmp.save
      end
    end
    
    if params[:decline] and @status != @GAST
      temp = User.find(params[:uid])
      if @trip.declined(temp)
        if current_user != temp
          tmp = Message.new()
          tmp.writer = current_user
          tmp.receiver = temp
          tmp.message = "Sie wurden fuer den Trip von "+@trip.start_city+" nach "+@trip.end_city+" abgelehnt!!"
          tmp.subject = "Ihre Bewerbung"
          tmp.delete_writer = true
          tmp.delete_receiver = false
          tmp.save
        end
      end
    end

    @commited_passenger = @trip.get_committed_passengers
    @uncommited_passenger = @trip.get_uncommitted_passengers
    @free_seats = @trip.get_free_seats
    @occupied_seats = @trip.get_occupied_seats
    @status = check(@trip)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @trip }
    end
  end

  # GET /trips/new
  # GET /trips/new.json
  def new
    @trip = Trip.new
    @fahrzeuge = current_user.cars

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @trip }
    end
  end

  # GET /trips/1/edit
  def edit
    @trip = Trip.find(params[:id])
  end

  # POST /trips
  # POST /trips.json
  def create
    #Die eingehenden Daten empfangen und an eine Methode übergeben, die ein Array an möglichen Orten zurückgeben
    #Redirecten mit Parametern? An die new Action?
    @trip = Trip.new()
    @trip.user_id = current_user.id
    @trip.car_id = params[:car]
    #@trip.start_zipcode = params[:address_start_plz]
    #@trip.start_street = params[:address_start_street]
    #@trip.start_city = params[:address_start_city]
    temp = Geocoder.coordinates(params[:address_start])
    @trip.starts_at_N = temp[0]
    @trip.starts_at_E = temp[1]
    #@trip.end_zipcode = params[:address_end_plz]
    #@trip.end_street = params[:address_end_street]
    #@trip.end_city = params[:address_end_city]
    temp = Geocoder.coordinates(params[:address_end])
    @trip.ends_at_N = temp[0]
    @trip.ends_at_E = temp[1]
    @trip.set_address_info
    @trip.set_route
    @trip.comment = params[:comment]
    #Hier Schwierigkeiten View != Model
    @trip.start_time = params[:start_year]+"-"+params[:start_month]+"-"+params[:start_day]+"T"+params[:start_hour]+":"+params[:start_minute]
    temp = Car.find(params[:car])
    if params[:free_seats] == ""
      @trip.free_seats = temp.seats
    else
      @trip.free_seats = params[:free_seats]
    end
    if params[:baggage] == nil
      @trip.baggage = false
    else
      @trip.baggage = true
    end
    puts @trip.start_city
    puts @trip.end_city
    puts @trip.start_time
    puts @trip.free_seats
    puts @trip.duration
    puts @trip.distance

    respond_to do |format|
      if @trip.save
        format.html { redirect_to @trip, notice: 'Trip was successfully created.' }
        format.json { render json: @trip, status: :created, location: @trip }
      else
        format.html { redirect_to trips_path }
        format.json { render json: @trip.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /trips/1
  # PUT /trips/1.json
  def update
    @trip = Trip.find(params[:id])
    if params[:request]
      current_user.bewerben(@trip)
    end

    respond_to do |format|
      if @trip.update_attributes(params[:trip])
        format.html { redirect_to @trip, notice: 'Trip was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @trip.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trips/1
  # DELETE /trips/1.json
  def destroy
    @trip = Trip.find(params[:id])
    @trip.destroy

    respond_to do |format|
      format.html { redirect_to trips_url }
      format.json { head :ok }
    end
  end
end

