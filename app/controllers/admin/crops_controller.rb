module Admin
    class CropsController < ApplicationController
      before_action :authenticate_admin!
      before_action :set_crop, only: [:show, :update, :destroy]
  
      # GET /admin/crops
      def index
        @crops = Crop.all
        render json: @crops
      end
  
      # GET /admin/crops/:id
      def show
        render json: @crop
      end
  
      # POST /admin/crops
      def create
        @crop = Crop.new(crop_params)
  
        if @crop.save
          render json: @crop, status: :created
        else
          render json: @crop.errors, status: :unprocessable_entity
        end
      end
  
      # PUT /admin/crops/:id
      def update
        if @crop.update(crop_params)
          render json: @crop
        else
          render json: @crop.errors, status: :unprocessable_entity
        end
      end
  
      # DELETE /admin/crops/:id
      def destroy
        @crop.destroy
        render json: { message: 'Crop deleted successfully.' }, status: :ok
      end
  
      private
  
      def set_crop
        @crop = Crop.find(params[:id])
      end
  
      def crop_params
        params.require(:crop).permit(:crop_name, :crop_price, :crop_status, :crop_expiry_date, :crop_quantity, :user_id)
      end
    end
  end
  