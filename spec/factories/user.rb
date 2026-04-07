FactoryBot.define do
  factory :user do
    # 名前がないとバリデーションに落ちるので、Fakerで20文字以内を生成
    name { Faker::Lorem.characters(number: Random.new.rand(1..20)) }

    # 重複エラーを防ぐために連番にする
    sequence(:email) {|n| "user_#{n}@example.com" }

    # 確実に 8 文字以上の複雑なパスワードを作る
    password { Faker::Internet.password(min_length: 8, max_length: 32, mix_case: true, special_characters: true) }
    password_confirmation { password }
  end
end
