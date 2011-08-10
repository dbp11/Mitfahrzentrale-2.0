class RequestsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource 
  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = "Zugriff verweigert!"
    redirect_to requests_path
  end
  #Exception, falls man auf einen Bereich nicht zugreifen kann
  rescue_from ActiveRecord::RecordNotFound do |exception|
    flash[:alert] = "Zugriff verweigert!"
    redirect_to requests_path
  end
  # Exception, falls ein Bereich nicht existiert
  rescue_from Exception::StandardError do |exception|
    flash[:alert] = exception.message
    redirect_to new_request_path
  end
  # Exception für Standardfehler, z.B. Eingabefehler

  # GET /requests
  # Liefert meine Requests, oder alle Request, wenn ich Admin bin
  def index
    if current_user.role == "admin"
      @requests = Request.all
    else
      @requests = current_user.get_own_requests
    end
  end

  # GET /requests/1
  # Liefert mir einen bestimmten Request von mir und die dazu passenden Trips
  def show
    @request = Request.find(params[:id])
    @sorted_trips = @request.get_sorted_trips
  end

  # GET /requests/new
  # Neue Request erstellen
  def new
    @request = Request.new
  end

  # GET /requests/1/edit
  # Request editieren
  # @params id die die zu editierende Request identifiziert
  def edit
    @request = Request.find(params[:id])
  end

  # POST /requests
  # Neue Request wird erstellt 
  def create
    # Coordinaten bestimmen, wenn nil, dann Exc. werfen
    start = Geocoder.coordinates(params[:request][:start_city])
    ende= Geocoder.coordinates(params[:request][:end_city])
    if start == nil
      raise "Starteingabe fehlerhaft"
    end
    if ende == nil
      raise "Zieleingabe fehlerhaft"
    end
    # Aus uebergebenen Parametern die Request bauen, die Coord. manuell eintragen
    @request = Request.new(params[:request])
    @request.user_id = current_user.id
    @request.starts_at_N = start[0]
    @request.starts_at_E = start[1]
    @request.ends_at_N = ende[0]
    @request.ends_at_E = ende[1]
    #Wie bei den Trips aus einer Eingabe drei Datenfelder machen, damit sie ins Modell passen
    # und duration und distance setzen
    @request = @request.set_address_info 
    @request.set_route

    if @request.save!
      redirect_to @request, notice: 'Request was successfully created.'
    else
      redirect_to requests_path
      render action: "new"
    end
  end

  # PUT /requests/1
  # Request nach editieren abdaten
  def update
    @request = Request.find(params[:id])
    if @request.update_attributes(params[:request])
      redirect_to @request, notice: 'Request was successfully updated.'
    else
      render action: "edit"
    end
  end

  # DELETE /requests/1
  # Request zerstoeren
  def destroy
    @request = Request.find(params[:id])
    @request.destroy
    redirect_to requests_url
  end
end
