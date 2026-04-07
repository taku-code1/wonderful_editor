require 'rails_helper'

RSpec.describe User, type: :model do
  describe "バリデーションテスト" do

    context "名前が20字以内であるとき" do
      it "有効であること" do
        user = build(:user, name: "a" * 20)
        expect(user).to be_valid
      end
    end

    context "名前が21字以上であるとき" do
      it "無効であること" do
        user = build(:user, name: "a" * 21)
        expect(user).not_to be_valid
      end
    end

    context "名前が空であるとき" do
      it "無効であること" do
        user = build(:user, name: nil)
        expect(user).not_to be_valid
      end
    end

    context "メールアドレスが重複していないとき" do
      it "有効であること" do
        user = build(:user, email: "unique@example.com")
        expect(user).to be_valid
      end
    end

    context "メールアドレスが重複しているとき" do
      it "無効であること" do
        create(:user, email: "test@example.com" )
        user = build(:user, email: "test@example.com")
        expect(user).not_to be_valid
      end
    end

    context "メールアドレスが空のとき" do
      it "無効であること" do
        user = build(:user, email: nil)
        expect(user).not_to be_valid
      end
    end

    context "パスワードが8文字のとき" do
      it "有効であること" do
        user = build(:user, password: "a" * 8)
        expect(user).to be_valid
      end
    end

    context "パスワードが8文字未満のとき" do
      it "無効であること" do
        user = build(:user, password: "a" * 7)
        expect(user).not_to be_valid
      end
    end

    context "パスワードが32文字のとき" do
      it "有効であること" do
        user = build(:user, password: "a" * 32)
        expect(user).to be_valid
      end
    end

    context "パスワードが33文字以上のとき" do
      it "無効であること" do
        user = build(:user, password: "a" * 33)
        expect(user).not_to be_valid
      end
    end

    context "パスワードが空のとき" do
      it "無効であること" do
        user = build(:user, password: nil)
        expect(user).not_to be_valid
      end
    end
  end
end
