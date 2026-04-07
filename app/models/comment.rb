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
class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :article

  validates :body, presence: { message: ": 内容を入力してください" }, length: { maximum: 200, message: ": 200文字以内で入力してください" }
end
