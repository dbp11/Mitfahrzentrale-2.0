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

  ##########################cars-controller####################################
  # Alles kommentiert
  # Ver. 1.0

  # GET /cars
  # Liefert die Autos des aktuellen Nutzers
  def index
    @cars = current_user.cars
  end

  # GET /cars/1
  # Liefert das Auto mit der entsprechenden ID in Detailansicht
  # @params id des zu Zeigenden Autos
  def show
    @car = Car.find(params[:id])
  end

  # GET /cars/new
  # Neues Auto
  def new
    @car = Car.new
  end

  # GET /cars/1/edit
  # Auto editieren
  # @params Auto mit der passenden id finden zum editieren
  def edit
    @car = Car.find(params[:id])
  end


  # POST /cars
  # Neues auto wird erstellt
  # @params Neues Car-Objekt wird mit den empfangenen Parametern befüllt
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
  # Car wird geupdated
  # @params Car-Objekt wird mit den empfangenen Parametern geupdated
  def update
    @car = Car.find(params[:id])

    if @car.update_attributes(params[:car])
      redirect_to @car, notice: 'Car was successfully updated.'
    else
      render action: "edit"
    end
  end

  # DELETE /cars/1
  # Entfernt ein bestimmtes Auto, wenn es nicht fuer ein Trip genutzt wird
  # @param id des zu loeschenden Autos
  def destroy
    @car = Car.find(params[:id])
    if @car.is_used
      redirect_to trips_path, notice: 'Das Auto wird fuer eine Fahrt genutzt und kann deshalb nicht entfernt werden.'
    else
      @car.destroy
      redirect_to cars_url
    end
  end
end
