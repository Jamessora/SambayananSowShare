# spec/factories/transactions.rb
FactoryBot.define do
  factory :transaction do
    association :buyer, factory: :user
    association :seller, factory: :user
    status { 'Pending' }
  end
end