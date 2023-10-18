class Admin::UsersController < ApplicationController
    include Rails.application.routes.url_helpers
      before_action :authenticate_admin!
  
      # GET /admin/users
      def index
        puts "Index method called"
        users = User.all
        response_data = users.map do |user|
            user_data = {
              id: user.id,
              email: user.email,
              fullName: user.fullName,
              birthday: user.birthday,
              address_country: user.address_country,
              address_city: user.address_city,
              address_baranggay: user.address_baranggay,
              address_street: user.address_street,
              kyc_status: user.kyc_status
            }
           
    
          end
        
        render json: response_data
    end

    
  
      # GET /admin/users/:id
      def show
        puts "Show method called with params: #{params[:id]}"
        user = User.find(params[:id])
        
        user_data = {
          id: user.id,
          email: user.email,
          fullName: user.fullName,
          birthday: user.birthday,
          address_country: user.address_country,
          address_city: user.address_city,
          address_baranggay: user.address_baranggay,
          address_street: user.address_street,
          kyc_status: user.kyc_status,
          crops: user.crops.map { |crop| 
            {
              id: crop.id,
              crop_name: crop.crop_name,
              crop_price: crop.crop_price,
              # ... other attributes
            }
          },
          bought_transactions: user.bought_transactions.map { |transaction| 
            {
              id: transaction.id,
              status: transaction.status,
              total_price: transaction.total_price,
              # ... other attributes
            }
          },
          sold_transactions: user.sold_transactions.map { |transaction| 
            {
              id: transaction.id,
              status: transaction.status,
              total_price: transaction.total_price,
              # ... other attributes
            }
          }
        }
        
        render json: user_data, status: :ok
      end

      #POST /admin/create
      def create
        puts "Debugging Params: #{params.inspect}"
        puts "Params: #{params}"
        puts "New User: #{User.new(params)}"

        begin
        @user = User.new(user_params)
        @user.skip_kyc_validation = true
      
        if @user.save
          render json: { message: 'User created successfully.'}, status: :ok
        else
            puts @user.errors.full_messages
            puts "Debugging: #{@user.inspect}"
            puts @user.errors.full_messages
          render json: { message: 'Failed to create user.' }, status: :unprocessable_entity
        end
        rescue => e
            puts "Exception: #{e.message}"
        end
      end
  
      # PUT /admin/users/:id
      def update
        user = User.find(params[:id])
  
        if user.update(user_params)
          render json: { message: 'User updated successfully.' }, status: :ok
        else
          render json: { message: 'Failed to update user.', errors: user.errors }, status: :unprocessable_entity
        end
      end
  
      # DELETE /admin/users/:id
      def destroy
        user = User.find(params[:id])
  
        if user.destroy
          render json: { message: 'User deleted successfully.' }, status: :ok
        else
          render json: { message: 'Failed to delete user.' }, status: :unprocessable_entity
        end
      end
  
      private
  
      def user_params
        params.require(:user).permit(
          :email, :password, :fullName, :birthday, :idType, :idNumber, :address_country,
          :address_city, :address_baranggay, :address_street, :kyc_status,
         
        )
      end
end

  