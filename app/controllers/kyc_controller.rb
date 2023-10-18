class KycController < ApplicationController
    before_action :authenticate_user!

    def new
      # Logic for showing a new KYC form
    end
  
    def create
        puts "Authorization Header: #{request.headers['Authorization']}"
        puts "Request Headers: #{request.headers}"

        if defined?(current_user)
            puts "Current User: #{current_user.inspect}"
          else
            puts "Current User is not defined"
        end

        if current_user.update(user_kyc_params)
          current_user.idPhoto.attach(params[:idPhoto])
            current_user.update(kyc_status: :pending)
            render json: { status: 'success', message: 'KYC submitted for approval.' }, status: :ok
        else
          puts current_user.errors.full_messages.to_sentence
            render json: { status: 'error', message: 'Failed to submit KYC details.' }, status: :unprocessable_entity
        end
    end
  
    def edit
      # Logic for editing existing KYC details
    end
  
    def update
        if current_user.update(user_kyc_params)
            current_user.idPhoto.purge if current_user.idPhoto.attached?
            current_user.idPhoto.attach(params[:idPhoto])
            current_user.update(kyc_status: :pending)
            render json: { status: 'success', message: 'KYC updated and resubmitted for approval.' }, status: :ok
        else 
          puts current_user.errors.full_messages.to_sentence
            render json: { status: 'error', message: 'Failed to update KYC details.' }, status: :unprocessable_entity
        end
    end


    private
  
    def user_kyc_params
      params.permit(:fullName, :birthday, 
        :address_country, :address_city, :address_baranggay, :address_street, 
        :idType, :idNumber, :idPhoto )
    end

end
