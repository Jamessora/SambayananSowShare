# frozen_string_literal: true

require 'googleauth'
require 'googleauth/stores/file_token_store'
# require 'google/apis/oauth2_v2'
# require 'google/apis/oauth2_v2_service'

class Users::SessionsController < Devise::SessionsController
  
  # before_action :authenticate_user!, only: [:destroy]
  skip_before_action :authenticate_user!, only: [:create, :new, :destroy]
  skip_before_action :verify_signed_out_user, only: [:destroy]

  
  def create
    user = nil
    puts "SessionsController#create: #{params.inspect}"
      # login logic 
      if params[:id_token]
      id_token = params[:id_token]
      validator = GoogleIDToken::Validator.new
      payload = validator.check(params[:id_token], Rails.application.credentials.dig(:GOOGLE_OAUTH_CLIENT_ID))
      user = User.find_by(google_id: payload['sub'])
      
    elsif params[:email] && params[:password]
      # Email/password login logic
      user = User.find_by(email: params[:email])
      user = user.valid_password?(params[:password]) ? user : nil
    end

      if user
        # Generate JWT token for the user
        Rails.logger.debug "User before generating JWT: #{user.inspect}"
        token = user.generate_jwt
        # Respond with the token and user id
        render json: { success: true, jwt: token, user_id: user.id, email: user.email }
      else
        render json: { success: false, error: 'Authentication failed' }
      end

    rescue GoogleIDToken::ValidationError => e
      render json: { success: false, error: e.message }
    end
  
  


 

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || root_path
  end

  # def destroy
  #   sign_out current_user
  #   JwtDenylist.create(jti: decoded_jwt['jti']) if decoded_jwt
  
   
  #   render json: { success: true, message: 'Logged out successfully' }
  #   status: :ok
  # end
#working spec
  # def destroy
  # token = request.headers['Authorization'].split(' ').last
  # decoded_token = decoded_jwt(token)
  
  # # Revoke JWT Token here (if using a revocation strategy)
  # JwtDenylist.create(jti: decoded_token['jti']) if decoded_token

  # # Sign out the user
  # sign_out current_user

  # # Send a success response
  # render json: {message: 'You have logged out successfully.'}, status: :ok
  # end

  # def destroy
  #   
  #   if @current_user
  #     # Decoded_jwt method sets a 'jti' field in the decoded token
  #     # Revoke JWT Token here (using a revocation strategy)
  #     jti = decoded_jwt(request.headers['Authorization'].split(' ').last)['jti']
  #     JwtDenylist.create(jti: jti) if jti
      
  #     # Sign out the user
  #     sign_out @current_user
      
  #     # Send a success response
  #     render json: { message: 'You have logged out successfully.' }, status: :ok
  #   else
  #     render json: { error: 'Unauthorized' }, status: :unauthorized
  #   end
  # end
  
  def destroy
    token = request.headers['Authorization'].split(' ').last
    decoded_token = decoded_jwt(token)
    

    if decoded_token.nil?
      render json: { error: 'Invalid token' }, status: :unauthorized
      return
    end
    # Revoke JWT Token here (if using a revocation strategy)
    JwtDenylist.create(jti: decoded_token['jti']) if decoded_token && !JwtDenylist.where(jti: decoded_token['jti']).exists?
    
    # Sign out the user
    sign_out current_user
    Rails.logger.debug "Signingout user" 
    
    # Send a success response
    render json: {message: 'You have logged out successfully.'}, status: :ok
  end

 
  private

  
  def decoded_jwt(token)
    decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base, true, { algorithm: 'HS256' })
    decoded_token.first # Return the payload
  rescue JWT::DecodeError => e
    Rails.logger.error "JWT Decode Error: #{e.message}"
    nil
  end

end
