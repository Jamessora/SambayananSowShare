# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]
  skip_before_action :authenticate_user!, only: [:google_oauth2]
  before_action :log_auth_hash, only: [:google_oauth2]
  # You should also create an action method in this controller like this:
  # def twitter
  # end

  def google_oauth2
    user = User.from_omniauth(auth)
    Rails.logger.debug "Inside google_oauth2"
    if user.present?
        Rails.logger.debug "Inside google_oauth2"
        after_oauth_signup(user) # Call the after_oauth_signup method here
        sign_out_all_scopes
        #flash[:success] = t 'devise.omniauth_calllbacks.success', kind: 'Google'
        render json: { success: true, message: "Successfully authenticated via Google" }
        sign_in_and_redirect user, event: :authentication
    else
        #flash[:alert] =
        #t 'devise.omniauth_callbacks.failure', kind: 'Google', reason: "#{auth.info.email} is not authorized"
        render json: { success: false, message: "Unsuccessful authentication via Google" }
        redirect_to new_user_session_path
    end

   
  end

  # More info at:
  # https://github.com/heartcombo/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end

  private
  
  def auth

    @auth ||= request.env['omniauth.auth']
  end

  def log_auth_hash
    Rails.logger.info "OmniAuth Auth Hash: #{auth.to_json}"
  end

   def after_oauth_signup(user)
    Rails.logger.debug "Inside after_oauth_signup: #{user.inspect}"
    user.generate_initial_password_token!
    Rails.logger.debug "After generating initial password token: #{user.initial_password_token}"
    UserMailer.set_initial_password_email(user).deliver_now
    Rails.logger.debug "Email should have been sent."
  end
end
