class Users::CropsController < ApplicationController
    before_action :authenticate_user!,  except: [:show_all]
    before_action :check_kyc_status, except: [:show_all]
    before_action :set_user, except: [:show_all]
    before_action :set_crop, only: [:show, :edit, :update, :destroy]
      
          def index
            Rails.logger.debug "Fetching all crops for user #{@user.id}"
            @crops = @user.crops
            render json: @crops
          end
      
          def show
            Rails.logger.debug "Fetching crop details for crop #{@crop.id}"
            render json: @crop
          end

          #For Viewing of all Crops not limited  to users
          def show_all
            Rails.logger.debug "Fetching all crops"
            @all_crops = Crop.all
            render json: @all_crops
          end
      
          def create
            Rails.logger.debug "Attempting to create new crop for user #{@user.id}"
            @crop = @user.crops.new(crop_params)
            if @crop.save
              render json: { status: 'success', message: 'Crop was successfully created.', crop: @crop }, status: :ok
            else
              render json: { status: 'error', message: @crop.errors.full_messages }, status: :unprocessable_entity
            end
          end
      
          def update
            Rails.logger.debug "Attempting to update crop #{@crop.id}"
            if @crop.update(crop_params)
              render json: { status: 'success', message: 'Crop was successfully updated.', crop: @crop }, status: :ok
            else
              render json: { status: 'error', message: @crop.errors.full_messages }, status: :unprocessable_entity
            end
          end
      
          def destroy
            Rails.logger.debug "Attempting to destroy crop #{@crop.id}"
            @crop.destroy
            render json: { status: 'success', message: 'Crop was successfully destroyed.' }, status: :ok
          end
      
          private
            def set_user
                @user = current_user
                Rails.logger.debug "Current User: #{@user.inspect}"
                Rails.logger.debug "Params User ID: #{params[:user_id]}"
                unless @user.id == params[:user_id].to_i
                  render json: { status: 'error', message: 'Unauthorized' }, status: :unauthorized
                end
            end
      
            def set_crop
              @crop = @user.crops.find(params[:id])
            end
      
            def crop_params
              params.require(:crop).permit(:crop_name, :crop_price, :crop_status, :crop_expiry_date, :crop_quantity)
            end

            def check_kyc_status
                unless current_user&.kyc_status == 'approved'
                  render json: { status: 'error', message: 'KYC approval is required to perform this action.' }, status: :forbidden
                end
            end

        
    
end
