class CarsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource 
  
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Zugriff verweigert!"
    redirect_to cars_path
  end
  rescue_from ActiveRecord::RecordNotFound do |exception|
    flash[:error] = "Zugriff verweigert!"
    redirect_to cars_path
  end  

  # GET /cars
  # GET /cars.json
  #@cars Liefert die Autos des aktuellen Nutzers
  def index
    @cars = current_user.cars
  end

  # GET /cars/1
  # GET /cars/1.json
  #@car Liefert das Auto mit der entsprechenden ID in Detailansicht
  def show
    @car = Car.find(params[:id])
  end

  # GET /cars/new
  # GET /cars/new.json
  # @car Neues Car-Objekt
  def new
    @car = Car.new
  end

  # GET /cars/1/edit
  #@car Auto mit der passenden id finden zum editieren
  def edit
    @car = Car.find(params[:id])
  end


  # POST /cars
  # POST /cars.json
  #@car Neues Car-Objekt wird mit den empfangenen Parametern befüllt
  def create
    @car = Car.new(params[:car])
    @car.user_id = current_user.id

    if @car.save
      redirect_to @car, notice: 'Car was successfully created.'
    else
      render action: "new"
    end
  end

  # PUT /cars/1
  # PUT /cars/1.json
  # @car Car-Objekt wird mit den empfangenen Parametern geupdated
  def update
    @car = Car.find(params[:id])

    if @car.update_attributes(params[:car])
      redirect_to @car, notice: 'Car was successfully updated.'
    else
      render action: "edit"
    end
  end

  # DELETE /cars/1
  # DELETE /cars/1.json
  # Car-Obkekt mit der passenden id löschen
  def destroy
    @car = Car.find(params[:id])
    if @car.is_used
      redirect_to trips_path, notice: 'Das Auto wird fuer eine Pfad genutzt und kann deshalb nicht entfernt werden.'
    else
      @car.destroy
      redirect_to cars_url
    end
  end
end
