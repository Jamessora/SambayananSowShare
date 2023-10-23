class ApplicationController < ActionController::API
    
    include Devise::Controllers::Helpers
    include ActionController::Flash
    include ActionController::MimeResponds

    

    before_action :authenticate_user!, if: :user_controller?

    def authenticate_user!
      Rails.logger.debug "Headers: #{request.headers.inspect}"
        token = request.headers['Authorization'].split(' ').last
        Rails.logger.debug "Received token: #{token}"
        
        # Logic to decode and validate token
        decoded_token = decoded_jwt(token)
        if decoded_token && decoded_token["id"]
          @current_user = User.find(decoded_token["id"])
          Rails.logger.debug "Authenticated User: #{current_user.inspect}"
        Rails.logger.debug "Decoded token: #{decoded_token}"
        Rails.logger.debug "Decoded token: #{@current_user}"
       
        else
          Rails.logger.debug "Authentication failed"
          render json: { error: 'Unauthorized' }, status: 401
        end
    end

    def authenticate_admin!
      token = request.headers['Authorization'].split(' ').last
      Rails.logger.debug "Received token: #{token}"
      Rails.logger.info "Received token: #{token}"
      decoded_token = decoded_jwt(token)
      Rails.logger.debug "Decoded token: #{decoded_token}"
      
      if decoded_token && Admin.find_by(id: decoded_token["admin_id"])
        Rails.logger.debug "Admin Authorized"
      else
        render json: { error: 'Unauthorized' }, status: 401
        Rails.logger.debug "Admin NOT Authorized"
      end
    end

    
    def decoded_jwt(token)
    decoded_token = JWT.decode(token, Rails.application.credentials.secret_key_base, true, { algorithm: 'HS256' })
                                      
    decoded_token.first # Return the payload
    rescue JWT::DecodeError => e
    Rails.logger.error "JWT Decode Error: #{e.message}"
    nil
    end

    private

    def user_controller?
        params[:controller].include?('users/')
      end

    
      
end
