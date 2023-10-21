# frozen_string_literal: true

class Admin::SessionsController < Devise::SessionsController
  #before_action :configure_sign_in_params, only: [:create]
  
  before_action :authenticate_admin!, only: [:destroy]
  respond_to :json 

 
  # POST /resource/sign_in
  def create
    Rails.logger.debug "Current Admin: #{current_admin.inspect}"
    Rails.logger.debug "Parameters: #{params.inspect}"
    admin = find_admin_by_email
    Rails.logger.debug "Email: #{params.dig(:admin, :email)}"
    Rails.logger.debug "Password: #{params.dig(:admin, :password)}"
    Rails.logger.debug "Admin found: #{admin.inspect}"
    Rails.logger.debug "Is password valid? #{valid_password?(admin)}"
    Rails.logger.debug "Is admin confirmed? #{admin.confirmed? if admin}"

    if admin.nil? || !valid_password?(admin)
      render_invalid_email_or_password
      Rails.logger.info("Invalid email or password")
    elsif !admin.confirmed?
      render_email_not_confirmed
      Rails.logger.info("admin not confirmed")
    else
      render_successful_login
      Rails.logger.info("Login success")
    end
  end

  # DELETE /resource/sign_out
  def destroy
    sign_out current_admin
    render json: { message: 'You have logged out successfully.' }, status: :ok
  end

  protected

   def require_no_authentication
    if request.format.json?
       assert_is_devise_resource!
       authenticated = warden.authenticated?(resource_name)
  
       if authenticated && resource = warden.user(resource_name)
         
         render_successful_login and return
         Rails.logger.info("Login success")
         return
       end
    else
       super
     end
   end
  
  private
  
  def find_admin_by_email
    Admin.find_by(email: params[:admin][:email])
  end
  
  def valid_password?(admin)
    admin&.valid_password?(params.dig(:admin, :password))
  end
  
  def render_invalid_email_or_password
    render json: { error: 'Invalid email or password.' }, status: :unauthorized
  end
  
  def render_email_not_confirmed
    render json: { error: 'Please confirm your email before logging in.' }, status: :unauthorized
  end
  
  def render_successful_login
    payload = { admin_id: current_admin.id }
    secret = Rails.application.secrets.secret_key_base
    token = JWT.encode(payload, secret, 'HS256')

    render json: {
      message: 'You are logged in.',
      success:true,
      admin: current_admin,
      jwt: token
    }, status: :ok
  end

  def set_flash_message(key, kind, options = {})
    # Do nothing when responding with JSON
    return if request.format.json?

    # Call the original method for other formats
    super
  end
end
