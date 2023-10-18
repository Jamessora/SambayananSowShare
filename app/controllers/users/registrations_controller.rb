# frozen_string_literal: true

require 'googleauth'
require 'googleauth/stores/file_token_store'

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  skip_before_action :authenticate_user!, only: [:create]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  def create
    # Your user creation logic here
    id_token = params[:id_token]
    Rails.logger.debug "Parameters: #{params.inspect}"
    validator = GoogleIDToken::Validator.new
    payload = validator.check(params[:id_token], Rails.application.credentials.dig(:GOOGLE_OAUTH_CLIENT_ID))
    user = User.find_by(google_id: payload['sub'])

    if user.nil?
      # Create a new user
      auth = OpenStruct.new(
        provider: 'google_oauth2',
        uid: payload['sub'],
        info: OpenStruct.new(
          email: payload['email'],
          first_name: payload['given_name'],
          last_name: payload['family_name'],
          image: payload['picture']
      ),
      extra: OpenStruct.new(
        id_info: OpenStruct.new(sub: payload['sub'])
      )
    )
    Rails.logger.debug "Before calling User.from_omniauth: #{auth.inspect}"
      user = User.from_omniauth(auth, send_email: true)
      Rails.logger.debug "After calling User.from_omniauth: #{user.inspect}"
      Rails.logger.debug "New User Created"
  end
      
      Rails.logger.debug "New User has_password value: #{user.has_password}"
   if !user.has_password
      Rails.logger.debug "User does not have a password"
      # Handle users who have not set their password yet
      user.generate_initial_password_token!
      puts "SendGrid API Key: #{ENV['SENDGRID_API_KEY']}"
      UserMailer.set_initial_password_email(user).deliver_now
    else
      Rails.logger.debug "User exists and has a password"
      # Your logic for existing users with a password
    end
    render json: { success: true, user_id: user.id, email: user.email }
  rescue GoogleIDToken::ValidationError => e
    render json: { success: false, error: e.message }
  end



  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is usefokaul if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
