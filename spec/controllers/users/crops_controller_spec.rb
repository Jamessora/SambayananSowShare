require 'rails_helper'

RSpec.describe Users::CropsController, type: :controller do
    include Devise::Test::ControllerHelpers

    before :each do
       @request.env["devise.mapping"] = Devise.mappings[:user]
       allow(controller).to receive(:authenticate_user!).and_return(true)
   end

  let(:user) { create(:user, kyc_status: kyc_status) }
  let(:kyc_status) {'approved'}
  let(:crop) { create(:crop, user: user) }
  let(:valid_attributes) { { crop_name: "Corn", crop_price: 100.0, crop_status: "available", crop_expiry_date: Date.today + 30.days, crop_quantity: 100 } }
  let(:invalid_attributes) { { crop_name: "", crop_price: nil, crop_status: "", crop_expiry_date: nil, crop_quantity: nil } }

  before do
    # Simulate user authentication
    sign_in user
  end

  describe "GET #index" do
    context "when kyc_status is approved" do
      it "returns a success response" do
        get :index, params: { user_id: user.id }
        expect(response).to have_http_status(:ok)
      end
    end

    context "when kyc_status is not approved" do
      let(:kyc_status) { 'pending' }
      
      it "returns a forbidden status" do
        get :index, params: { user_id: user.id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { id: crop.id, user_id: user.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST #create" do
    context "when kyc_status is approved" do
        context "with valid params" do
          it "creates a new Crop" do
            expect {
              post :create, params: { crop: valid_attributes, user_id: user.id }
            }.to change(Crop, :count).by(1)
          end
    
          it "returns a success response" do
            post :create, params: { crop: valid_attributes, user_id: user.id }
            expect(response).to have_http_status(:ok)
          end
        end
    
        context "with invalid params" do
          it "does not create a new Crop" do
            expect {
              post :create, params: { crop: invalid_attributes, user_id: user.id }
            }.to change(Crop, :count).by(0)
          end
    
          it "returns an unprocessable_entity status" do
            post :create, params: { crop: invalid_attributes, user_id: user.id }
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end
    
      context "when kyc_status is not approved" do
        let(:kyc_status) { 'pending' }
    
        it "returns a forbidden status" do
          post :create, params: { crop: valid_attributes, user_id: user.id }
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { crop_name: "Wheat" } }

      it "updates the requested crop" do
        put :update, params: { id: crop.id, crop: new_attributes, user_id: user.id }
        crop.reload
        expect(crop.crop_name).to eq("Wheat")
      end

      it "returns a success response" do
        put :update, params: { id: crop.id, crop: valid_attributes, user_id: user.id }
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      it "returns an unprocessable entity status" do
        put :update, params: { id: crop.id, crop: invalid_attributes, user_id: user.id }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested crop" do
      crop = Crop.create! valid_attributes.merge(user: user)
      expect {
        delete :destroy, params: { id: crop.id, user_id: user.id }
      }.to change(Crop, :count).by(-1)
    end

    it "returns a success response" do
      delete :destroy, params: { id: crop.id, user_id: user.id }
      expect(response).to have_http_status(:ok)
    end
  end
end
