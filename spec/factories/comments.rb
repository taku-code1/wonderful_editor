# == Schema Information
#
# Table name: comments
#
#  id         :bigint           not null, primary key
#  body       :text
#  user_id    :bigint           not null
#  article_id :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :comment do
    # 本文：1〜200文字の範囲でランダムに生成（モデルの制限に合わせました）
    body { Faker::Lorem.characters(number: Random.new.rand(1..200)) }

    # 関連付け：コメントを作成するときに、自動でユーザーと記事も作成される。
    association :user
    association :article
  end
end
