class RegistrationController < Devise::RegistrationsController
  prepend_before_filter :require_no_authentication, :only => [ :new, :create, :cancel ]
  prepend_before_filter :authenticate_scope!, :only => [:edit, :update, :destroy]
  include Devise::Controllers::InternalHelpers

  def new
    super
  end

  def create

    build_resource

    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with resource, :location => redirect_location(resource_name, resource)
      else
        set_flash_message :notice, :inactive_signed_up, :reason => inactive_reason(resource) if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords(resource)
      respond_with_navigational(resource) { render_with_scope :new }
    end  
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
    hash ||= params[resource_name] || {}
    self.resource = resource_class.new_with_session(hash, session)
  end

  def after_sign_up_path_for(resource)
    redirect_to user_url(current_user.id)
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
