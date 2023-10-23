class Users::TransactionsController < ApplicationController
    include UserActions
    
    before_action :authenticate_user!
    before_action :check_kyc_status
    before_action :set_user
    

    def index
      role = params[:role] || 'seller'  # Default to 'seller' if role is not specified
    
      if role == 'seller'
        transactions = Transaction.where(seller_id: current_user.id)
      elsif role == 'buyer'
        transactions = Transaction.where(buyer_id: current_user.id)
      else
        return render json: { error: 'Invalid role specified' }, status: :bad_request
      end
    
      transactions = transactions.where.not(status: 'Pending')
                               .joins(transaction_crops: :crop)
                               .includes(transaction_crops: :crop)
                               .joins('INNER JOIN users AS buyers ON transactions.buyer_id = buyers.id')
                               .joins('INNER JOIN users AS sellers ON transactions.seller_id = sellers.id')
                               .select('transactions.*, buyers."fullName" as buyer_name, sellers."fullName" as seller_name,
                                      buyers."address_country" as buyer_country, buyers."address_city" as buyer_city,
                                      buyers."address_baranggay" as buyer_baranggay, buyers."address_street" as buyer_street')
      render json: transactions, include: { transaction_crops: { include: :crop } }, status: :ok
    end
    
    def show
      transaction = Transaction.find_by(id: params[:id], buyer_id: current_user.id)
      if transaction
        render json: { status: 'success', transaction: transaction }, status: :ok
      else
        render json: { status: 'error', message: 'Transaction not found' }, status: :not_found
      end
    end
    

    def create
      Rails.logger.debug "Creating a new transaction"
      
      crop = Crop.find_by(id: params[:crop_id])
      if crop.nil?
        render json: { status: 'error', message: 'Crop not found' } and return
      end
  
      existing_transaction = Transaction.find_by(buyer_id: current_user.id, seller_id: crop.user_id, status: 'Pending')

      if existing_transaction
          @transaction = existing_transaction
        else
        @transaction = Transaction.new(
          buyer_id: current_user.id, 
          seller_id: crop.user_id,
          status: 'Pending'
        )

        unless @transaction.save
          Rails.logger.error "Error creating transaction: #{@transaction.errors.full_messages.join(", ")}"
          render json: { status: 'error', message: @transaction.errors.full_messages } and return
        end
      end
    
    # Common response for both existing and new transactions
    Rails.logger.debug "Transaction processed successfully"
    render json: { status: 'success', transaction: @transaction }
  end
  
    def update
      Rails.logger.debug "Updating transaction"
      
      @transaction = Transaction.find_by(id: params[:id])
      Rails.logger.debug "Fetched Transaction: #{@transaction.inspect}"
      if @transaction.nil?
        render json: { status: 'error', message: 'Transaction not found' }, status: :not_found and return
      end
    
      new_status = params[:status]
      Rails.logger.debug "New Status: #{new_status}"
      
     
      allowed_statuses = case current_user
      when @transaction.buyer
        ['For Seller Confirmation', 'Payment Sent For Seller Confirmation', 'Completed']
      when @transaction.seller
        ['For Buyer Payment', 'For Delivery']
      else
        []
      end
      Rails.logger.debug "Allowed Statuses: #{allowed_statuses.inspect}"
      
      

      if allowed_statuses.include?(new_status)
        # Update the total_price only when the status is 'For Seller Confirmation'
        if new_status == 'For Seller Confirmation'
          
          total_price = @transaction.transaction_crops.sum(:price)
          Rails.logger.debug "Inside For Seller Confirmation block. Starting price calculation."

          if @transaction.update(status: new_status, total_price: total_price, status_updated_at: DateTime.now)
            Rails.logger.debug "Transaction updated successfully inside seller confirmation"
            render json: { status: 'success', message: 'Transaction updated successfully', transaction: @transaction }, status: :ok
          else
            Rails.logger.debug "Transaction update failed: #{@transaction.errors.full_messages.join(", ")}"
            render json: { status: 'error', message: @transaction.errors.full_messages.join(", ") }, status: :unprocessable_entity
          end
        else
          @transaction.update(status: new_status)
          Rails.logger.debug "Transaction updated successfully not inside seller confirmation"
          render json: { status: 'success', message: 'Transaction updated successfully', transaction: @transaction }, status: :ok
        end
      else
        render json: { status: 'error', message: 'Invalid status' }, status: :bad_request
      end
    end
  end
  