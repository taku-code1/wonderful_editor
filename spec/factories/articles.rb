# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  title      :string
#  body       :text
#  user_id    :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :article do
    # タイトル：1〜30文字の範囲でランダムに生成（モデルの maximum: 30 に合わせました）
    title { Faker::Lorem.characters(number: Random.new.rand(1..30)) }

    # 本文：ランダムな文章を生成
    body { Faker::Lorem.paragraph }

    # 関連付け：記事を作成するときに、自動で投稿者（User）も作成されるようにします
    association :user
  end
end
