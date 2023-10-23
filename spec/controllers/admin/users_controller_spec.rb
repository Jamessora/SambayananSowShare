require 'rails_helper'


def generate_jwt_for_admin(admin)
  payload = { admin_id: admin.id }
  JWT.encode(payload, Rails.application.credentials.secret_key_base, 'HS256')
end

RSpec.describe Admin::UsersController, type: :controller do
    include Devise::Test::ControllerHelpers
    let(:admin) { create(:admin) }  
    let(:token) { generate_jwt_for_admin(admin) }
    let(:user) { create(:user) }

    before do
      allow(controller).to receive(:authenticate_admin!).and_return(true)


    # Manually set current_admin
    allow(controller).to receive(:current_admin).and_return(admin)
    end
  
    describe 'GET #index' do
      it 'returns a success response' do
        get :index
        Rails.logger.debug "response #{response}"
        expect(controller.current_admin).to eq(admin)
        expect(response).to be_successful
      end
    end
    describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { id: user.id }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST #create' do
    it 'creates a new user and returns a success response' do
      post :create, params: { user: attributes_for(:user) } # attributes_for is a FactoryBot method
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PUT #update' do
    it 'updates an existing user and returns a success response' do
      put :update, params: { id: user.id, user: { email: 'new_email@example.com' } }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested user and returns a success response' do
      delete :destroy, params: { id: user.id }
      expect(response).to have_http_status(:ok)
    end
  end
end
