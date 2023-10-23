require 'rails_helper'

  def generate_jwt(admin)
    JWT.encode({ admin_id: admin.id }, Rails.application.credentials.secret_key_base, 'HS256')
  end
  
  def generate_jwt_for_user(user)
    payload = { id: user.id }
    JWT.encode(payload, Rails.application.credentials.secret_key_base, 'HS256')
  end

  RSpec.describe "Admin Authentication", type: :controller do
    
    controller do

    before_action :authenticate_admin!
      def index
        render json: { message: 'Hello' }, status: :ok
      end
    end
  
    let(:admin) { create(:admin) }
    let(:token) { generate_jwt(admin) }
  
    describe '#authenticate_admin!' do
      context 'when admin is authenticated' do
        before do
          request.headers['Authorization'] = "Bearer #{token}"
          Rails.logger.debug "Token authorized: #{token}"
          Rails.logger.debug "Token authorized: #{response.body}"
          Rails.logger.debug "Token authorized: #{response.status}"
          routes.draw { get 'index' => 'anonymous#index' }
          get :index
        end
  
        it 'should return a successful response' do
          expect(response).to have_http_status(:ok)
        end
      end
  
      context 'when admin is not authenticated' do
        before do
          request.headers['Authorization'] = 'Invalid Token'
          Rails.logger.debug "Token unauthorized: #{token}"
          Rails.logger.debug "Token unauthorized response body: #{response.body}"
          Rails.logger.debug "Token unauthorized response status: #{response.status}"
          routes.draw { get 'index' => 'anonymous#index' }
          get :index
        end
  
        it 'should return unauthorized' do

          expect(response).to have_http_status(:unauthorized)
          Rails.logger.debug "Token unauthorized: #{response}"
        end
      end
    end
  end


    RSpec.describe "User Authentication", type: :controller do
    controller do
      before_action :authenticate_user!
      def index
        render json: { message: 'Hello' }, status: :ok
      end
    end
  
    let(:user) { create(:user) } # 
    let(:user_token) { generate_jwt_for_user(user) }
  
    describe '#authenticate_user!' do
      context 'when user is authenticated' do
        before do
          request.headers['Authorization'] = "Bearer #{user_token}"
          routes.draw { get 'index' => 'anonymous#index' }
          Rails.logger.debug "User token: #{user_token}"
          get :index
        end
  
        it 'should return a successful response' do
          expect(response).to have_http_status(:ok)
        end
      end

        
      context 'when user is not authenticated' do
        before do
          allow(controller).to receive(:decoded_jwt).and_return(nil)  # Mock to return nil
          request.headers['Authorization'] = 'Invalid Token'
          routes.draw { get 'index' => 'anonymous#index' }
          get :index
        end
    
        it 'should return unauthorized when decoded_token is nil' do
          expect(response).to have_http_status(:unauthorized)
        end
      end
    
      context 'when user is not authenticated and decoded_token does not contain id' do
        before do
          allow(controller).to receive(:decoded_jwt).and_return({ "some_key" => "some_value" })  # Mock to return hash without id
          request.headers['Authorization'] = 'Invalid Token'
          routes.draw { get 'index' => 'anonymous#index' }
          get :index
        end
    
        it 'should return unauthorized when decoded_token does not contain id' do
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end

  RSpec.describe "Testing decoded_jwt method in ApplicationController", type: :controller do
    controller(ApplicationController) do
      # A public method that calls the private `decoded_jwt` method.
      def public_decoded_jwt(token)
        decoded_jwt(token)
      end
    end
  
    describe '#decoded_jwt' do
      let(:secret_key) { Rails.application.credentials.secret_key_base }
      let(:valid_payload) { { user_id: 1 } }
      let(:invalid_payload) { { user_id: 'invalid' } }
  
      context 'when the token is valid' do
        let(:valid_token) { JWT.encode(valid_payload, secret_key, 'HS256') }
  
        it 'returns the decoded payload' do
          decoded_payload = controller.send(:public_decoded_jwt, valid_token)
          expect(decoded_payload).to eq(valid_payload.stringify_keys)
        end
      end
  
      context 'when the token is invalid' do
        let(:invalid_token) { 'invalid_token' }
  
        it 'returns nil' do
          decoded_payload = controller.send(:public_decoded_jwt, invalid_token)
          expect(decoded_payload).to be_nil
        end
      end
  
      context 'when the token has an invalid signature' do
        let(:invalid_signature_token) { JWT.encode(valid_payload, 'invalid_key', 'HS256') }
  
        it 'returns nil' do
          decoded_payload = controller.send(:public_decoded_jwt, invalid_signature_token)
          expect(decoded_payload).to be_nil
        end
      end
    end
  
    
  end
