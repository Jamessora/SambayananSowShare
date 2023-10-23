class Admin::TransactionsController < ApplicationController
      before_action :authenticate_admin!
  
      # GET /admin/transactions
      # def index
      #   transactions = Transaction.all.includes(transaction_crops: :crop)
      #   render json: transactions, include: { transaction_crops: { include: :crop } }, status: :ok
      # end

      def index
        transactions = Transaction.all.includes(:buyer, :seller, transaction_crops: :crop)
        render json: transactions, include: { buyer: { only: [:fullName, :address_country, :address_city, :address_baranggay, :address_street] }, 
                                              seller: { only: [:fullName, :address_country, :address_city, :address_baranggay, :address_street] },
                                              transaction_crops: { include: :crop } }, status: :ok
      end
      
      # def index
      #   transactions = Transaction.all.includes(:buyer, :seller, transaction_crops: :crop)
      #   puts "Transactions: #{transactions.inspect}"
      #   transaction_data = transactions.map do |transaction|
      #     puts "Transaction: #{transaction.inspect}"  # Log 2
      #     puts "Buyer: #{transaction.buyer.inspect}"  # Log 3
      #     puts "Seller: #{transaction.seller.inspect}"  # Log 3
      #     {
      #       id: transaction.id,
      #       buyer_name: transaction.buyer.fullName,
      #       seller_name: transaction.seller.fullName,
      #       buyer_country: transaction.buyer.address_country,
      #       buyer_city: transaction.buyer.address_city,
      #       buyer_baranggay: transaction.buyer.address_baranggay,
      #       buyer_street: transaction.buyer.address_street,
      #       seller_country: transaction.seller.address_country,
      #       seller_city: transaction.seller.address_city,
      #       seller_baranggay: transaction.seller.address_baranggay,
      #       seller_street: transaction.seller.address_street,
      #       transaction_crops: transaction.transaction_crops.map do |transaction_crop|
      #         {
      #           crop_name: transaction_crop.crop.name,
      #           # add other crop attributes here
      #         }
      #       end
      #     }
      #   end

      #   render json: transaction_data, status: :ok
      # end
  
      # GET /admin/transactions/:id
      def show
        transaction = Transaction.includes(:buyer, :seller, transaction_crops: :crop)
                                 .find(params[:id])
      
        render json: transaction, include: { 
          buyer: { only: [:fullName, :address_country, :address_city, :address_baranggay, :address_street] },
          seller: { only: [:fullName, :address_country, :address_city, :address_baranggay, :address_street] },
          transaction_crops: { include: :crop }
        }, status: :ok
      end
  
      # PUT /admin/transactions/:id
      def update
        transaction = Transaction.find(params[:id])
  
        if transaction.update(transaction_params)
          render json: { message: 'Transaction updated successfully.' }, status: :ok
        else
          render json: { message: 'Failed to update transaction.', errors: transaction.errors }, status: :unprocessable_entity
        end
      end
  
      # DELETE /admin/transactions/:id
      def destroy
        transaction = Transaction.find(params[:id])
  
        if transaction.destroy
          render json: { message: 'Transaction deleted successfully.' }, status: :ok
        else
          render json: { message: 'Failed to delete transaction.' }, status: :unprocessable_entity
        end
      end
  
      private
  
      def transaction_params
        params.require(:transaction).permit(:buyer_id, :seller_id, :status, :total_price, transaction_crops_attributes: [:id, :crop_id, :quantity, :price, :_destroy])
      end
    end

  