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
    body { Faker::Lorem.sentence }
    # 以下の2行を書くと、userとarticleを作って紐付けをしてくれる。
    association :user
    association :article
  end
end
