require 'rails_helper'

RSpec.describe Users::TransactionCropsController, type: :controller do
  include Devise::Test::ControllerHelpers

  before :each do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    allow(controller).to receive(:authenticate_user!).and_return(true)
  end

  let(:buyer) { create(:user, kyc_status: 'approved') }
  let(:seller) { create(:user, kyc_status: 'approved') }
  let(:crop) { create(:crop, user: seller, crop_quantity: 10, crop_price: 5) }
  
  let(:transaction) { create(:transaction, buyer: buyer, seller: seller) }
  let(:transaction_crop) { create(:transaction_crop, transaction_record: transaction, crop: crop) }
  before do
    sign_in buyer
  end

  describe 'POST #create' do
    context 'when crop does not exist' do
      it 'returns a not found message' do
        puts "Debug: Crop ID: #{crop.id}"
        puts "Debug: Crop actually in DB: #{Crop.find_by(id: crop.id).inspect}"
        puts "Debug: Transaction ID: #{transaction.id}"
        post :create, params: { 
      user_id: buyer.id, 
      transaction_id: transaction.id, 
      transaction_crop: { crop_id: -1, quantity: 1 }
    }
        expect(response.body).to match(/Crop not found/)
      end
    end

    context 'when not enough quantity' do
      it 'returns an error message' do
        # post :create, params: { user_id: buyer.id, transaction_id: transaction.id, crop_id: crop.id, quantity: 20 }
        puts "Debug: Crop Quantity in DB: #{Crop.find_by(id: crop.id).crop_quantity}"
        puts "Debug: Transaction actually in DB: #{Transaction.find_by(id: transaction.id).inspect}"

        post :create, params: { 
          user_id: buyer.id, 
          transaction_id: transaction.id, 
          transaction_crop: { transaction_id: transaction.id, crop_id: crop.id, quantity: 20 }
        }
        expect(response.body).to match(/Not enough quantity available/)
      end
    end

    context 'when transaction crop is successfully created' do
      it 'returns a success message and status code' do
        #post :create, params: { user_id: buyer.id, transaction_id: transaction.id, transaction_crop: { transaction_id: transaction.id, crop_id: crop.id, quantity: 5 } }
        puts "Debug: Crop ID from test: #{crop.id}"
        puts "Debug: Transaction actually successful transaction in DB: #{Transaction.find_by(id: transaction.id).inspect}"
        post :create, params: { 
          user_id: buyer.id, 
          transaction_id: transaction.id, 
          transaction_crop: { transaction_id: transaction.id, crop_id: crop.id, quantity: 5 }
        }
        expect(response.body).to match(/success/)
        expect(response.status).to eq(200)
      end
    end

    context 'when a pending transaction and transaction crop already exist' do
      it 'updates the existing transaction crop instead of creating a new one' do
        existing_transaction_crop = create(:transaction_crop, transaction_record: transaction, crop: crop, quantity: 2)
        
        expect {
          post :create, params: { 
            user_id: buyer.id, 
            transaction_id: transaction.id, 
            transaction_crop: { transaction_id: transaction.id, crop_id: crop.id, quantity: 3 }
          }
        }.not_to change(TransactionCrop, :count)
        
        existing_transaction_crop.reload
        expect(existing_transaction_crop.quantity).to eq(5) # 2 original + 3 new
      end
    end
    
    context 'when transaction crop is successfully created or updated' do
      it 'updates the crop quantity' do
        original_crop_quantity = crop.crop_quantity # assuming this is set to some initial value
        
        post :create, params: { 
          user_id: buyer.id, 
          transaction_id: transaction.id, 
          transaction_crop: { transaction_id: transaction.id, crop_id: crop.id, quantity: 5 }
        }
        
        crop.reload
        expect(crop.crop_quantity).to eq(original_crop_quantity - 5)
      end
    end
  end

  describe 'PATCH #update' do
    let(:transaction_crop) { create(:transaction_crop, transaction_record: transaction, crop: crop) }

    it 'updates the transaction crop' do
      puts "Debug: Transaction Crop ID: #{transaction_crop.id}"
      #patch :update, params: { user_id: buyer.id, transaction_id: transaction.id, id: transaction_crop.id, quantity: 2 }
      patch :update, params: { 
        user_id: buyer.id, 
        transaction_id: transaction.id, 
        id: transaction_crop.id, 
        transaction_crop: { transaction_id: transaction.id, crop_id: crop.id, quantity: 2 }
      }
      expect(response.body).to match(/success/)
      expect(response.status).to eq(200)
    end
  end

  describe 'DELETE #destroy' do
    let(:transaction_crop) { create(:transaction_crop, transaction_record: transaction, crop: crop) }

    it 'deletes the transaction crop' do
      delete :destroy, params: { user_id: buyer.id, transaction_id: transaction.id, id: transaction_crop.id }
      expect(response.body).to match(/success/)
      expect(response.status).to eq(200)
    end
  end
end