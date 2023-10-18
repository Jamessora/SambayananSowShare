FactoryBot.define do
  factory :transaction_crop do
    quantity { rand(1..10) }
    association :transaction_record, factory: :transaction, alias: :transaction
    association :crop, factory: :crop

    after(:build) do |transaction_crop|
      transaction_crop.price = transaction_crop.quantity * transaction_crop.crop.crop_price
    end
  end
end
