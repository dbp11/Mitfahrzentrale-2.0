class PassengersController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource 
  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = "Zugriff verweigert!"
    redirect_to trips_path
  end
  rescue_from ActiveRecord::RecordNotFound do |exception|
    flash[:alert] = "Zugriff verweigert!"
    redirect_to trips_path
  end
  
  # GET /passengers
  # Liste aller Passenger
  # @params Liste
  def index
    @passengers = Passenger.all
  end

  # GET /passengers/1
  # Ein bestimmten Passenger zeigen
  # @param id anhand der Passenger identifiziert wird
  def show
    @passenger = Passenger.find(params[:id])
  end

  # GET /passengers/new
  # 
  def new
    @passenger = Passenger.new
  end

  # GET /passengers/1/edit
  def edit
    @passenger = Passenger.find(params[:id])
  end

  # POST /passengers
  # POST /passengers.json
  def create
    @passenger = Passenger.new(params[:passenger])
    if @passenger.save
      redirect_to @passenger, notice: 'Passenger was successfully created.'
    else
      render action: "new"
    end
  end

  # PUT /passengers/1
  # PUT /passengers/1.json
  def update
    @passenger = Passenger.find(params[:id])
    if @passenger.update_attributes(params[:passenger])
      redirect_to @passenger, notice: 'Passenger was successfully updated.'
    else
      render action: "edit"
    end
  end

  # DELETE /passengers/1
  # DELETE /passengers/1.json
  def destroy
    @passenger = Passenger.find(params[:id])
    @passenger.destroy
    redirect_to passengers_url
  end
end
