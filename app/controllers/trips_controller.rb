class TripsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource 
  
  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = "Zugriff verweigert!"
    redirect_to trips_path
  end
  #Exception, falls man auf einen Bereich nicht zugreifen kann
  rescue_from ActiveRecord::RecordNotFound do |exception|
    flash[:alert] = "Zugriff verweigert!"
    redirect_to trips_path
  end
  # Exception, falls ein Bereich nicht existiert
  rescue_from Exception::StandardError do |exception|
    flash[:alert] = exception.message 
    redirect_to trips_path
  end
  #Exception-Handling

  # Checkt, welche Rolle der User in einem bestimmten Trip einnimmt
  # @params trp zu prüfender Trip
  # @return Rolle des eingeloggten Users
  def check (trp)
    @trip = trp
    @FAHRER = 0
    @MITFAHRER = 1
    @POTENTIELLER_MITFAHRER = 2
    @GAST = 3
    @user = current_user
    if current_user == @trip.user || current_user.role == "admin"
      @status = @FAHRER
      # User hat den Trip erstellt => er ist der Fahrer
      # bzw. er ist der Admin
    elsif @trip.user_committed(current_user)
      @status = @MITFAHRER
      # User ist ein Mitfahrer
    elsif @trip.user_uncommitted(current_user)
      @status = @POTENTIELLER_MITFAHRER
      # User hat eine Anfrage auf Mitfahrerschaft gestellt
    else
      @status = @GAST
      #User ist ein Gast
    end
    return @status
  end

  # GET /trips
  # Liefert Übersicht über alle Fahrten an denen der Nutzer beteiligt ist und war
  def index
    if current_user.role == "admin"
      @trips = current_user.driven
      @future_trips = Trip.all
      @completed_trips = nil
      @ridden_trips = nil
      @future_ridden_trips = nil
    else
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
    end
  end

  # GET /trips/1
  # Liefert eine bestimmte Fahrt
  def show
    @FAHRER = 0
    @MITFAHRER = 1
    @POTENTIELLER_MITFAHRER = 2
    @GAST = 3
    # Konstanten, welche die möglichen Rollen  
    @user = current_user
    @trip = Trip.find(params[:id])

    @status = check(@trip)
    # Rolle des Users wird gesetzt
    @free_seats = @trip.get_free_seats
    @occupied_seats = @trip.get_occupied_seats
    # ermitteln der genutzten und freien Plätze
    
    # Methode, welche Mitteilungen an die Beteiligten eine Mitfahrerbewerbung verschicken lässt
    if params[:request]
      if current_user.bewerben(@trip)
        #Message an den potentiellen Mitfahrer
        tmp = Message.new()
        tmp.writer = User.find(@trip.user_id)
        tmp.receiver = current_user
        tmp.subject = "[[/trips/"+@trip.id.to_s+"|"+@trip.start_city+" - "+@trip.end_city+"]]"
        tmp.message = "Ihre Bewerbung fuer die Fahrt von "+@trip.start_city+" nach "+@trip.end_city+" war erfolgreich. <3"        
        tmp.delete_writer = true
        tmp.delete_receiver = false
        puts tmp.to_s
        tmp.save
        # Message an den Fahrer
        tmp = Message.new()
        tmp.writer = current_user 
        tmp.receiver = User.find(@trip.user_id)
        tmp.subject = "[[/trips/"+@trip.id.to_s+"|"+@trip.start_city+" - "+@trip.end_city+"]]"
        tmp.message = "Bewerbung fuer die Fahrt von "+@trip.start_city+" nach "+@trip.end_city+".\n Nutzer annehmen: [[/trips/"+@trip.id.to_s+"?accept=true&uid="+current_user.id.to_s+"|Hier!]]"        

        tmp.delete_writer = true
        tmp.delete_receiver = false
        tmp.save
      end
    end

    # Methode, welche eine Mitteilung an einen angenommenen Mitfahrer versendet
    if params[:accept] and @status == @FAHRER
      temp = User.find(params[:uid])
      if @trip.get_free_seats > 0
        if @trip.accept(temp)
          tmp = Message.new()
          tmp.writer = current_user
          tmp.receiver = temp
          tmp.message = "Sie wurden fuer die Fahrt von "+@trip.start_city+" nach "+@trip.end_city+" angenommen!!"
          tmp.subject = "[[/trips/"+@trip.id.to_s+"|"+@trip.start_city+" - "+@trip.end_city+"]]"
          tmp.delete_writer = true
          tmp.delete_receiver = false
          tmp.save
        end
      end
    end
    
    # Methode, welche eine Mitteilung an einen abgelehnten Bewerber geschickt wird
    if params[:decline] and @status != @GAST
      temp = User.find(params[:uid])
      if @trip.declined(temp)
        if current_user != temp
          tmp = Message.new()
          tmp.writer = current_user
          tmp.receiver = temp
          tmp.message = "Sie wurden fuer die Fahrt von "+@trip.start_city+" nach "+@trip.end_city+" abgelehnt!!"
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
    # Informationsübergabe
    end

  # GET /trips/new
  # Neuer Trip
  def new
    if !current_user.cars.empty?
      @trip = Trip.new
      @fahrzeuge = current_user.cars
    else
      redirect_to trips_url, :notice => "Bitte erst Auto anmelden!"
    end
  end

  # GET /trips/1/edit
  def edit
    @trip = Trip.find(params[:id])
  end

  # POST /trips
  # Methode erstellt ein neuen Trip
  def create
    # Neuer trip wird angelegt, Nutzer bin ich, car wird aus Parameter ausgelesen und eingetragen
    @trip = Trip.new()
    @trip.user_id = current_user.id
    @trip.car_id = params[:car]

    # Anahnd der Parameter wird die Geocoder-Coord. bestimmt, wenn sie nil ist schmeißen wir eine Exc.
    temp = Geocoder.coordinates(params[:address_start])
    if temp != nil
      @trip.starts_at_N = temp[0]
      @trip.starts_at_E = temp[1]
    else
      raise "Fehler bei der Starteingabe"
    end
    temp = Geocoder.coordinates(params[:address_end])
    if temp != nil
      @trip.ends_at_N = temp[0]
      @trip.ends_at_E = temp[1]
    else
      raise "Fehler in der Zieleingabe"
    end
    
    # set_address_info macht aus einem Addresseingabefeld drei Teile, so dass es in das Model eingetragen werden kann
    # set_route bestimmt distance und duration
    @trip = @trip.set_address_info
    @trip.set_route
    
    # Comment wird eingefuegt
    @trip.comment = params[:comment]
    # Die fuenf Eingabewerte der View werden zusammengefuegt, damit sie in ein Datenfeld des Models passen
    @trip.start_time = params[:start_year]+"-"+params[:start_month]+"-"+params[:start_day]+"T"+params[:start_hour]+":"+params[:start_minute]
    # Verfuegbare Sitzplaetze des Trips werden gesetzt
    if params[:free_seats] == ""
      @trip.free_seats = @trip.car.seats
    else
      @trip.free_seats = params[:free_seats]
    end
    # Ist der Fahrer bereit Gepaeck mitzunehmem?
    if params[:baggage] == nil
      @trip.baggage = false
    else
      @trip.baggage = true
    end

    if @trip.save
      redirect_to @trip, :notice => 'Die Fahrt wurde erfolgreich erstellt.'
    else
      redirect_to trips_path
    end
  end

  # PUT /trips/1
  # PUT /trips/1.json
  def update
    @trip = Trip.find(params[:id])
    if params[:request]
      current_user.bewerben(@trip)
    end
    if @trip.update_attributes(params[:trip])
      redirect_to @trip, :notice => 'Die Fahrt wurde erfolgreich aktualisiert.'
    else
      render :action => "edit"
    end
  end

  # DELETE /trips/1
  # DELETE /trips/1.json
  def destroy
    @trip = Trip.find(params[:id])
    if @trip.start_time > Time.now
      @trip.destroy
      redirect_to trips_url
    else
      redirect_to trips_url, :notice => "Vergangene Fahrten koennen nicht geloescht werden"
    end
  end
end

