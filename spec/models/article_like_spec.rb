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
require 'rails_helper'

RSpec.describe ArticleLike, type: :model do
  let(:user) { create(:user) }
  let(:article) { create(:article) }

  describe "バリデーションのテスト" do

    context "同じ記事に同じユーザーがいいねしようとしたとき" do
      it "無効であること" do
        create(:article_like, user: user, article: article)
        article_like2 = build(:article_like, user: user, article: article)
        expect(article_like2).not_to be_valid
      end
    end
  end
end
