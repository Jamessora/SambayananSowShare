module Admin
    class TransactionsController < ApplicationController
      before_action :authenticate_admin!
  
      # GET /admin/transactions
      def index
        transactions = Transaction.all.includes(transaction_crops: :crop)
        render json: transactions, include: { transaction_crops: { include: :crop } }, status: :ok
      end
  
      # GET /admin/transactions/:id
      def show
        transaction = Transaction.find(params[:id])
        render json: transaction, include: { transaction_crops: { include: :crop } }, status: :ok
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
  end
  