class RequestsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource 
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Zugriff verweigert!"
    redirect_to requests_path
  end
  rescue_from ActiveRecord::RecordNotFound do |exception|
    flash[:error] = "Zugriff verweigert!"
    redirect_to requests_path
  end

  # GET /requests
  # GET /requests.json
  def index
    if current_user.role == "admin"
      @requests = Request.all
    else
      @requests = current_user.get_own_requests
    end
  end

  # GET /requests/1
  # GET /requests/1.json
  def show
    @request = Request.find(params[:id])
    @sorted_trips = @request.get_sorted_trips
  end

  # GET /requests/new
  # GET /requests/new.json
  def new
    @request = Request.new
  end

  # GET /requests/1/edit
  def edit
    @request = Request.find(params[:id])
  end

  # POST /requests
  # POST /requests.json
  def create
    #@request = Request.new(params[:request])
    start = Geocoder.coordinates(params[:request][:start_city])
    ende= Geocoder.coordinates(params[:request][:end_city])
    @request = Request.new(params[:request])
    @request.user_id = current_user.id
    @request.starts_at_N = start[0]
    @request.starts_at_E = start[1]
    @request.ends_at_N = ende[0]
    @request.ends_at_E = ende[1]
    @request = @request.set_address_info 
    @request.set_route

    if @request.save!
      redirect_to @request, notice: 'Request was successfully created.'
    else
      redirect_to requests_path, notice: 'Speicherfehler - Deine Schuld DATUM Validation!'
      render action: "new"
    end
  end

  # PUT /requests/1
  # PUT /requests/1.json
  def update
    @request = Request.find(params[:id])
    if @request.update_attributes(params[:request])
      redirect_to @request, notice: 'Request was successfully updated.'
    else
      render action: "edit"
    end
  end

  # DELETE /requests/1
  # DELETE /requests/1.json
  def destroy
    @request = Request.find(params[:id])
    @request.destroy
    redirect_to requests_url
  end
end
