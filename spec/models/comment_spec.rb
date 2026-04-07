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
require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:user) { create(:user) }
  let(:article) { create(:article) }

  describe 'バリデーションのテスト' do

    context "コメントがあり、200文字以内で書かれているとき" do
      it "有効であること" do
        comment = build(:comment, body: "a" * 200, user: user, article: article)
        expect(comment).to be_valid
      end
    end

    context "コメントがあるが、201文字以上で書かれているとき" do
      it "無効であること" do
        comment = build(:comment, body: "a" * 201, user: user, article: article)
        expect(comment).not_to be_valid
      end
    end

    context "コメントがないとき" do
      it "無効であること" do
        comment = build(:comment, body: nil, user: user, article: article)
        expect(comment).not_to be_valid
      end
    end
  end
end
