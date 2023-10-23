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

  describe 'GET #index' do
    context 'when role is seller' do
      it 'returns transactions where the current user is the seller' do
        get :index, params: { user_id: buyer.id, role: 'seller' }
        expect(response).to have_http_status(:ok)
        
      end
    end

    context 'when role is buyer' do
      it 'returns transactions where the current user is the buyer' do
        get :index, params: { user_id: buyer.id, role: 'buyer' }
        expect(response).to have_http_status(:ok)
        
      end
    end

    context 'when role is invalid' do
      it 'returns a bad request status' do
        get :index, params: { user_id: buyer.id, role: 'invalid_role' }
        expect(response).to have_http_status(:bad_request)
      end
    end
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

    context 'when crop is not found' do
      it 'returns an error' do
        post :create, params: { user_id: buyer.id, crop_id: 'non_existent_crop_id' }
        expect(response).to have_http_status(:ok) # or whatever your app returns for this case
        expect(JSON.parse(response.body)['status']).to eq('error')
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

    context 'when transaction ID is valid' do
      it 'updates the transaction status' do
        put :update, params: { user_id: buyer.id, id: transaction.id, status: 'For Seller Confirmation' }
        transaction.reload
        expect(transaction.status).to eq('For Seller Confirmation')
        expect(response).to have_http_status(:ok)
      end
  
      it 'returns an error for an invalid status' do
        put :update, params: { user_id: buyer.id, id: transaction.id, status: 'Invalid Status' }
        expect(response).to have_http_status(:bad_request)
      end
    end
  
    context 'when transaction ID is invalid' do
      it 'returns a not found status' do
        put :update, params: { user_id: buyer.id, id: 'invalid_transaction_id', status: 'For Seller Confirmation' }
        expect(response).to have_http_status(:not_found)
      end
    end
  
    context 'when update fails' do
      before do
        allow_any_instance_of(Transaction).to receive(:update).and_return(false)
      end
  
      it 'returns an unprocessable entity status' do
        put :update, params: { user_id: buyer.id, id: transaction.id, status: 'For Seller Confirmation' }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
    describe 'GET #show' do
    let(:transaction) { create(:transaction, buyer: buyer, seller: seller) }

    context 'when transaction ID is valid' do
      it 'returns the transaction' do
        get :show, params: { user_id: buyer.id, id: transaction.id }
        expect(response).to have_http_status(:ok)
        # Add more expectations here to check the returned JSON
      end
    end

    context 'when transaction ID is invalid' do
      it 'returns a not found status' do
        get :show, params: { user_id: buyer.id, id: 'invalid_transaction_id'}
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
