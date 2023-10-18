class Admin::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def is_flashing_format?
      false
    end
  
  private
  def respond_with(resource, _opts = {})
      puts "Debugging: Resource attributes: #{resource.attributes}"
      puts "Debugging: Resource errors: #{resource.errors.full_messages}"
  
      # Add this line for debugging
      raise "Resource is nil" if resource.nil?

      if resource.persisted?
        register_success && return
      else
        register_failed
      end
  end

  def register_success
    token = resource.confirmation_token # Devise should automatically generate this for you
    opts = {}  # Add any additional options here if needed
    AdminMailer.confirmation_instructions(@admin, token).deliver_now

    render json: {
      message: 'Signed up successfully.'
    }, 
    status: :ok
  end

  def register_failed
      render json: {
          message: "Admin couldn't be created, signed up failed.",
          errors: resource.errors.full_messages
      },
      status: :unprocessable_entity
  end
end      