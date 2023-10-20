# frozen_string_literal: true

class Admin::ConfirmationsController < Devise::ConfirmationsController
  
  def show
      Rails.logger.debug "Inside Admin::ConfirmationsController#show"
      self.resource = resource_class.confirm_by_token(params[:confirmation_token])
      Rails.logger.debug "Resource Errors: #{resource.errors.full_messages}"
      if resource.errors.empty?
        
        # Redirect to React frontend with success status
        redirect_to "https://sambayanansowsharefe.onrender.com/confirmation-success?status=success",  allow_other_host: true
      else
        # Redirect to React frontend with failure status
        puts "Debugging: Resource errors: #{resource.errors.full_messages}"
        redirect_to "https://sambayanansowsharefe.onrender.com/confirmation-success?status=failure",  allow_other_host: true
      end
    end
  
    
  
  



  end
