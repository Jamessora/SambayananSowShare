# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  skip_before_action :authenticate_user!, only: [:new, :update]

  # POST /users/set_initial_password
  def new
    token = params[:token]
    Rails.logger.debug "New action triggered. Token received: #{token}"
    user = User.find_by(initial_password_token: token)
    Rails.logger.debug "Database token: #{user.initial_password_token}, Param token: #{token}"
    Rails.logger.debug "Database token timestamp: #{user.initial_password_token_sent_at}, Current Time: #{Time.now}"
    if user && user.initial_password_token_sent_at > 2.hours.ago
      Rails.logger.debug "Token is valid"
      render json: { success: true, message: 'Token is valid' }
      
    else
      Rails.logger.debug "Invalid or expired token"
      render json: { success: false, message: 'Invalid or expired token' }, status: :unprocessable_entity
    end
  end

  def update
    token = params[:token]
    password = params[:password]

    Rails.logger.debug "Update action triggered. Token received: #{token}"
    user = User.find_by(initial_password_token: token)

    if user && user.initial_password_token_sent_at > 2.hours.ago
      Rails.logger.debug "Token is valid"

      user.skip_kyc_validation = true
      user.password = password
      user.initial_password_token = nil
      user.initial_password_token_sent_at = nil

      if user.save
        Rails.logger.debug "Password set successfully"
        render json: { success: true, message: 'Password set successfully' }
      else
        Rails.logger.debug "Failed to set password: #{user.errors.full_messages.join(', ')}"
        Rails.logger.debug "Failed to set password"
        render json: { success: false, message: 'Failed to set password' }, status: :unprocessable_entity
      end
    else
      Rails.logger.debug "Invalid or expired token"
      render json: { success: false, message: 'Invalid or expired token' }, status: :unprocessable_entity
    end
  end
  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  # def create
  #   super
  # end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
end
