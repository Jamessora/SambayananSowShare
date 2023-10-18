# spec/controllers/users/transactions_controller_spec.rb
require 'rails_helper'

RSpec.describe Users::TransactionsController, type: :controller do
  include Devise::Test::ControllerHelpers

  before :each do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    allow(controller).to receive(:authenticate_user!).and_return(true)
  end

  let(:buyer) { create(:user, kyc_status: 'approved') }
  let(:seller) { create(:user, kyc_status: 'approved') }
  let(:crop) { create(:crop, user: seller) }

  before do
    # Simulate user authentication
    sign_in buyer
  end

  describe 'POST #create' do
    context 'when kyc_status is approved' do
      before { buyer.update(kyc_status: 'approved') }

      it 'creates a new transaction if no existing pending transaction' do
        post :create, params: { user_id: buyer.id, crop_id: crop.id }
        expect(Transaction.count).to eq(1)
      end

      it 'uses existing transaction if one is pending' do
        existing_transaction = create(:transaction, buyer: buyer, seller: seller, status: 'Pending')
        post :create, params: { user_id: buyer.id, crop_id: crop.id }
        expect(Transaction.count).to eq(1) # should still be 1, not create a new one
      end

      it 'sets the transaction status to Pending' do
        post :create, params: { user_id: buyer.id, crop_id: crop.id }
        expect(Transaction.last.status).to eq('Pending')
      end
    end

    context 'when kyc_status is not approved' do
      before { buyer.update(kyc_status: 'rejected') }

      it 'does not create a new transaction' do
        post :create, params: { user_id: buyer.id, crop_id: crop.id }
        expect(Transaction.count).to eq(0)
      end
    end
  end


  describe 'PUT #update' do
    let(:transaction) { create(:transaction, buyer: buyer, seller: seller, status: 'Pending') }
    let(:crop1) { create(:crop, user: seller, crop_price: 100, crop_quantity: 5) }
    let(:crop2) { create(:crop, user: seller, crop_price: 200, crop_quantity: 5) }
    let!(:transaction_crop1) { create(:transaction_crop, transaction_record: transaction, price: 100, crop: crop1, quantity: 1) }
    let!(:transaction_crop2) { create(:transaction_crop, transaction_record: transaction, price: 200, crop: crop2, quantity: 1) }
    
    
    context 'when kyc_status is approved' do
      before { buyer.update(kyc_status: 'approved') }
  
      it 'updates the transaction status' do
        
        puts "Transaction Crops: #{transaction.transaction_crops.inspect}"
        put :update, params: { user_id: buyer.id, id: transaction.id, status: 'For Seller Confirmation' }
        transaction.reload
        puts "transaction status after reload: #{transaction.status}"
        expect(transaction.status).to eq('For Seller Confirmation')
      end
  
      it 'updates the transaction total_price when status is For Seller Confirmation' do
       puts "Transaction Crops: #{transaction.transaction_crops.inspect}"
        put :update, params: { user_id: buyer.id, id: transaction.id, status: 'For Seller Confirmation' }
        transaction.reload
        puts "Transaction Crops after reloading: #{transaction.transaction_crops.inspect}"
        puts "Transaction after reloading: #{transaction.inspect}"
        puts "Individual Prices after reloading: #{transaction.transaction_crops.map(&:price)}"


        puts "Total Price after reloading: #{transaction.total_price}"
        
        expect(transaction.total_price).to eq(300) # 100 from transaction_crop1 and 200 from transaction_crop2
      end
    end
  
    context 'when kyc_status is not approved' do
      before { buyer.update(kyc_status: 'rejected') }
  
      it 'does not update the transaction' do
        put :update, params: { user_id: buyer.id, id: transaction.id, status: 'For Seller Confirmation' }
        transaction.reload
        expect(transaction.status).to_not eq('For Seller Confirmation')
      end
  
      it 'does not update the transaction total_price' do
        put :update, params: { user_id: buyer.id, id: transaction.id, status: 'For Seller Confirmation' }
        transaction.reload
        expect(transaction.total_price).to_not eq(300) # Assuming initial total_price was not 300
      end
    end
  end
end
