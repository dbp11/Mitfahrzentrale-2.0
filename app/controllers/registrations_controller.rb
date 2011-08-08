class RegistrationController < Devise::RegistrationsController
  prepend_before_filter :require_no_authentication, :only => [ :new, :create, :cancel ]
  prepend_before_filter :authenticate_scope!, :only => [:edit, :update, :destroy]
  include Devise::Controllers::InternalHelpers

  def new
    super
  end

  def create
    super
  end

  def edit
    super
  end

  def update
    super
  end

  def destroy
    if current_user.driver_trips
      flash[:error] = "Sie koennen ihren Account nicht loeschen, da Sie noch ausstehende Fahrten anbieten!"
      redirect_to trips_url
    else
      current_user.car do |car|
        car.destroy
      end
      super
    end
  end

  def cancel
    super
  end

  protected

  def build_resource(hash=nil)
    super
  end

  def after_sign_up_path_for(resource)
    redirect_to trips_path 
  end

  def redirect_location(scope, resource)
    super
  end

  def inactive_reason(resource)
    super
  end

  def after_inactive_sign_up_path_for (resource)
    super
  end

  def after_update_path_for (resource)
    super
  end

  def authenticate_scope!
    super
  end

end
