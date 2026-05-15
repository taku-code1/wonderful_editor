FactoryBot.define do
  factory :article do
    title { Faker::Lorem.characters(number: 30) }
    body { Faker::Lorem.sentence }
    association :user

    # デフォルトのステータス追加
    status { :draft }

    # :draftというオプションを呼んだら、statusを下書き（:draft）にしてという指示
    trait :draft do
      status { :draft }
    end

    # :publishedというオプションを呼んだら、statusを公開（:published）にしてという指示
    trait :published do
      status { :published }
    end
  end
end
