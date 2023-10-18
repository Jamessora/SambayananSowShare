module UserActions
    extend ActiveSupport::Concern
    
    
    private
  
    def set_user
      @user = current_user
      Rails.logger.debug "Current User: #{@user.inspect}"
      Rails.logger.debug "Params User ID: #{params[:user_id]}"
      unless @user.id == params[:user_id].to_i
        render json: { status: 'error', message: 'Unauthorized' }, status: :unauthorized
      end
    end
  
    def check_kyc_status
      unless current_user&.kyc_status == 'approved'
        render json: { status: 'error', message: 'KYC approval is required to perform this action.' }, status: :forbidden
      end
    end
  end
  