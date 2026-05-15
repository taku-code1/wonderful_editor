require "rails_helper"

RSpec.describe "Api::V1::Auth::Registrations", type: :request do
  describe "POST /api/v1/auth" do
    subject { post(api_v1_user_registration_path, params: params) }

    context "必要な情報が存在するとき" do
      # ユーザー登録に必要なデータを事前に準備
      let(:params) { attributes_for(:user) }

      it "ユーザーの新規登録ができる" do
        expect { subject }.to change { User.count }.by(1)
        expect(response).to have_http_status(:ok)
        res = JSON.parse(response.body)
        expect(res["data"]["email"]).to eq(User.last.email)
      end

      it "ヘッダー情報を取得できる" do
        subject
        header = response.header
        expect(header["access-token"]).to be_present
        expect(header["client"]).to be_present
        expect(header["expiry"]).to be_present
        expect(header["uid"]).to be_present
        expect(header["token-type"]).to be_present
      end
    end

    context "nameが存在しないとき" do
      let(:params) { attributes_for(:user, name: nil) }

      it "エラーする" do
        expect { subject }.not_to change { User.count }
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(res["errors"]["name"]).to include "can't be blank"
      end
    end

    context "emailが存在しないとき" do
      let(:params) { attributes_for(:user, email: nil) }

      it "エラーする" do
        expect { subject }.not_to change { User.count }
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(res["errors"]["email"]).to include "can't be blank"
      end
    end

    context "emailが重複しているとき" do
      # 同じメアドのユーザーを事前に準備
      before { create(:user, email: "test@example.com") }

      # 同じメアドをパラメータにセット
      let(:params) { attributes_for(:user, email: "test@example.com") }

      it "エラーする" do
        expect { subject }.not_to change { User.count }
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(res["errors"]["email"]).to include "has already been taken"
      end
    end

    context "passwordが存在しないとき" do
      let(:params) { attributes_for(:user, password: nil) }

      it "エラーする" do
        expect { subject }.not_to change { User.count }
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(res["errors"]["password"]).to include "can't be blank"
      end
    end

    context "確認用パスワードが間違っていたとき" do
      let(:params) { attributes_for(:user, password: "password", password_confirmation: "mismatch") }

      it "エラーする" do
        expect { subject }.not_to change { User.count }
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(res["errors"]["password_confirmation"]).to include "doesn't match Password"
      end
    end
  end
end
