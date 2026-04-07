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
require "rails_helper"

RSpec.describe Article, type: :model do
  let(:user) { create(:user) }

  describe "バリデーションのテスト" do
    context "タイトルがあり、30文字以内であるとき" do
      it "有効であること" do
        article = build(:article, title: "a" * 30, user: user)
        expect(article).to be_valid
      end
    end

    context "タイトルはあるが、30文字以上であるとき" do
      it "無効であること" do
        article = build(:article, title: "a" * 31, user: user)
        expect(article).not_to be_valid
      end
    end

    context "タイトルがないとき" do
      it "無効であること" do
        article = build(:article, title: nil, user: user)
        expect(article).not_to be_valid
      end
    end

    context "本文があるとき" do
      it "有効であること" do
        article = build(:article, body: "hello", user: user)
        expect(article).to be_valid
      end
    end

    context "本文がないとき" do
      it "無効であること" do
        article = build(:article, body: nil, user: user)
        expect(article).not_to be_valid
      end
    end
  end
end
