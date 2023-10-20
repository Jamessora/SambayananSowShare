class Users::TransactionCropsController < ApplicationController
  include UserActions

  before_action :authenticate_user!
  before_action :check_kyc_status
  before_action :set_user
  before_action :set_transaction, only: [:create, :update, :destroy]
  
  def index
    transaction_crops = TransactionCrop.joins(:transaction_record)
                                              .where(transactions: { buyer_id: params[:user_id], status: 'Pending' })
                                              .order('created_at ASC')
                                              .includes(:crop)
                                              
    render json: { status: 'success', transaction_crops: transaction_crops }, include: [:crop],  status: :ok
  end


  def create
    ActiveRecord::Base.transaction do
      Rails.logger.debug "Attempting to create new transaction crop"
      Rails.logger.debug "Crop: #{Crop.find_by(id: params[:crop_id])}"
      Rails.logger.debug "Params: #{params}"
      puts "Controller Debug: Crop ID from params: #{params[:crop_id]}"
      
 
      transaction_crop_params = params.require(:transaction_crop).permit(:transaction_id, :crop_id, :quantity)
      crop = Crop.find_by(id: transaction_crop_params[:crop_id])
      if crop.nil?
        Rails.logger.error "Crop not found for ID: #{params[:crop_id]}"
        render json: { status: 'error', message: 'Crop not found' } and return
      end
  
      if crop.crop_quantity <  transaction_crop_params[:quantity].to_i
        Rails.logger.debug "Crop quantity: #{crop.crop_quantity}, Requested quantity: #{ transaction_crop_params[:quantity].to_i}"
        puts "Crop quantity: #{crop.crop_quantity}, Requested quantity: #{ transaction_crop_params[:quantity].to_i}"
        Rails.logger.error "Not enough quantity for crop ID: #{params[:crop_id]}"
        render json: { status: 'error', message: 'Not enough quantity available' } and return
      end
  
      transaction = Transaction.find_by(id: transaction_crop_params[:transaction_id])
      existing_transaction_crop = TransactionCrop.find_by(transaction_id: transaction_crop_params[:transaction_id], crop_id: transaction_crop_params[:crop_id])
  
      if transaction&.status == 'Pending' && existing_transaction_crop
        # Calculate the new quantity for the existing TransactionCrop
        new_quantity_for_existing_transaction_crop = existing_transaction_crop.quantity + transaction_crop_params[:quantity].to_i
        
        # Update the existing TransactionCrop
        existing_transaction_crop.update(
          price: new_quantity_for_existing_transaction_crop * crop.crop_price,
          quantity: new_quantity_for_existing_transaction_crop
        )
      
        # Update the crop quantity
        new_crop_quantity = crop.crop_quantity - transaction_crop_params[:quantity].to_i
        crop.update(crop_quantity: new_crop_quantity)
      
        render json: { status: 'success', transaction_crop: existing_transaction_crop }, status: :ok
      else
      @transaction_crop = TransactionCrop.new(transaction_crop_params)
      @transaction_crop.price = @transaction_crop.quantity * crop.crop_price
  
      if @transaction_crop.save
        # Update the crop quantity
        new_quantity = crop.crop_quantity - transaction_crop_params[:quantity].to_i
        crop.update(crop_quantity: new_quantity)
  
        Rails.logger.debug "Transaction Crop created successfully with ID: #{@transaction_crop.id}"
        render json: { status: 'success', transaction_crop: @transaction_crop }, status: :ok
      else
        Rails.logger.error "Error creating Transaction Crop: #{@transaction_crop.errors.full_messages.join(", ")}"
        render json: { status: 'error', message: @transaction_crop.errors.full_messages }, status: :bad_request
      end
    end
  end
  end
  
  
  # def update
  #   begin
  #     Rails.logger.debug "Attempting to update Transaction Crop with ID: #{params[:id]}"
  #     Rails.logger.debug "@transaction_crop.quantity: #{@transaction_crop.quantity}"
  #     Rails.logger.debug "@transaction_crop.crop.crop_price: #{@transaction_crop.crop.crop_price}"
  #     puts "Controller Debug: Crop ID from params: #{params[:crop_id]}"
  #     @transaction_crop = TransactionCrop.find(params[:id])
  #     @transaction_crop.quantity = params[:quantity]
  #     @transaction_crop.price = @transaction_crop.quantity * @transaction_crop.crop.crop_price
  
  #     if @transaction_crop.update(transaction_crop_params)
  #       Rails.logger.debug "Transaction Crop updated successfully with ID: #{params[:id]}"
  #       render json: { status: 'success', transaction_crop: @transaction_crop }, status: :ok
  #     else
  #       Rails.logger.error "Error updating Transaction Crop: #{params[:id]}, Errors: #{@transaction_crop.errors.full_messages.join(", ")}"
  #       render json: { status: 'error', message: @transaction_crop.errors.full_messages }
  #     end
  #   rescue ActiveRecord::RecordNotFound => e
  #     Rails.logger.error "Transaction Crop not found for ID: #{params[:id]}"
  #     render json: { status: 'error', message: 'Transaction Crop not found' }, status: :not_found
  #   end
  # end
  def update
    begin
      Rails.logger.debug "Attempting to update Transaction Crop with ID: #{params[:id]}"
      @transaction_crop = TransactionCrop.find(params[:id])
      Rails.logger.debug "@transaction_crop.quantity: #{@transaction_crop.quantity}"
      
      # Update the attributes using transaction_crop_params
      if @transaction_crop.update(transaction_crop_params)
        
        # Compute the price separately
        @transaction_crop.price = @transaction_crop.quantity * @transaction_crop.crop.crop_price
        
        # Save the updated price
        if @transaction_crop.save
          Rails.logger.debug "Transaction Crop updated successfully with ID: #{params[:id]}"
          render json: { status: 'success', transaction_crop: @transaction_crop }, status: :ok
        else
          Rails.logger.error "Error updating Transaction Crop price: #{@transaction_crop.errors.full_messages.join(", ")}"
          render json: { status: 'error', message: @transaction_crop.errors.full_messages }
        end
      else
        Rails.logger.error "Error updating Transaction Crop: #{params[:id]}, Errors: #{@transaction_crop.errors.full_messages.join(", ")}"
        render json: { status: 'error', message: @transaction_crop.errors.full_messages }
      end
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error "Transaction Crop not found for ID: #{params[:id]}"
      render json: { status: 'error', message: 'Transaction Crop not found' }, status: :not_found
    end
  end
  
  def destroy
    begin
      Rails.logger.debug "Attempting to delete Transaction Crop with ID: #{params[:id]}"
      @transaction_crop = TransactionCrop.find(params[:id])
  
      if @transaction_crop.destroy
        Rails.logger.debug "Transaction Crop deleted successfully with ID: #{params[:id]}"
        render json: { status: 'success', message: 'Transaction crop deleted successfully' }
      else
        Rails.logger.error "Failed to delete Transaction Crop with ID: #{params[:id]}"
        render json: { status: 'error', message: 'Failed to delete transaction crop' }
      end
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error "Transaction Crop not found for ID: #{params[:id]}"
      render json: { status: 'error', message: 'Transaction Crop not found' }
    end
  end


  private

  def transaction_crop_params
    params.require(:transaction_crop).permit(:transaction_id, :crop_id, :quantity)
  end

  def set_transaction
    @transaction = Transaction.find_by(id: params[:transaction_id])
    render json: { status: 'error', message: 'Transaction not found' } if @transaction.nil?
  end
end

