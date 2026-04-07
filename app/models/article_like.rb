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
class ArticleLike < ApplicationRecord
  belongs_to :user
  belongs_to :article

  validates :user_id, uniqueness: { scope: :article_id }
end
