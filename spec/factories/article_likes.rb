# == Schema Information
#
# Table name: article_likes
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  article_id :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :article_like do
    # 関連付け：いいねを作るときに、自動でユーザーと記事も作成します
    association :user
    association :article
  end
end
