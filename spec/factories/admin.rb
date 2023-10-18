# spec/factories/admins.rb

FactoryBot.define do
    factory :admin do
        sequence(:email) { |n| "admin#{n}@example.com" }
      password { "password123" }
      # Add other fields here as required for your model
  
      trait :another_trait do
        # Different attributes for a different context
      end
    end
  end
  