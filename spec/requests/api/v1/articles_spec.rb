require "rails_helper"
# index開始
# --------------------------------------------------------------------------------
RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET /api/v1/articles" do
    # 【共通設定】テスト対象のURL
    subject { get(api_v1_articles_path) }

    # 並び順をテストする際は、比較対象のデータが必要
    let!(:article1) { create(:article, updated_at: 1.days.ago) }
    let!(:article2) { create(:article, updated_at: 2.days.ago) }
    let!(:article3) { create(:article) }

    it "ログインしていなくても（誰でも）、記事一覧を取得できること" do
      subject
      expect(response).to have_http_status(:ok) # ステータスコードは200であること
    end

    it "サーバーから返ってきた記事が3つあること" do
      subject
      res = JSON.parse(response.body)
      expect(res.length).to eq 3
    end

    it "記事が更新順に並んでいること" do
      subject
      res = JSON.parse(response.body)
      expect(res.map {|d| d["id"] }).to eq [article3.id, article1.id, article2.id]
    end

    it "記事の一覧機能のレスポンスには本文が含まれていないこと" do
      subject
      res = JSON.parse(response.body)
      expect(res[0].keys).to eq ["id", "title", "updated_at", "user"]
      expect(res[0].keys).not_to include("body")
    end

    it "投稿者の情報が含まれていること" do
      subject
      res = JSON.parse(response.body)
      # UserSerializerが正しく動いているかチェック
      expect(res[0]["user"].keys).to eq ["id", "name", "email"]
    end
  end
  # --------------------------------------------------------------------------------
  # index終了

  describe "GET /api/v1/articles/:id" do
    subject { get(api_v1_article_path(article_id)) }

    context "指定したidの記事が存在する場合" do
      let(:article) { create(:article) }
      let(:article_id) { article.id }

      it "記事の詳細が取得できる" do
        subject
        res = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(res["id"]).to eq article.id
        expect(res["title"]).to eq article.title
        expect(res["body"]).to eq article.body
        expect(res["updated_at"]).to be_present
        expect(res["user"]["id"]).to eq article.user.id
        expect(res["user"].keys).to eq ["id", "name", "email"]
      end
    end

    context "指定したidの記事が存在しないとき" do
      let(:article_id) { 100000 }

      it "記事が見つからない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "POST /api/v1/articles" do
    subject { post(api_v1_articles_path, params: params) }

    let(:params) { { article: attributes_for(:article) } }
    let(:current_user) { create(:user) }

    # スタブの設定
    before do
      allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user)
    end

    it "記事を作成できる" do
      expect { subject }.to change { Article.where(user_id: current_user.id).count }.by(1)
      res = JSON.parse(response.body)
      expect(res["title"]).to eq params[:article][:title]
      expect(res["body"]).to eq params[:article][:body]
      expect(response).to have_http_status(:ok)
    end

    context "不適切なパラメーターを送信したとき" do
      # 空のデータを送る
      let(:params) { { article: { title: "", body: "" } } }

      it "記事の作成に失敗する" do
        expect { subject }.not_to change { Article.count }
        expect(response).to have_http_status(:unprocessable_entity) # 422エラーが返るか
      end
    end
  end

  describe "PATCH /api/v1/articles" do
    subject { patch(api_v1_article_path(article), params: params) }

    let(:params) { { article: { title: "タイトル更新", body: "本文更新" } } }
    let(:current_user) { create(:user) }
    before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) }

    context "記事を更新するとき" do
      # 自分の記事を準備
      let(:article) { create(:article, user: current_user) }

      it "正常に更新できる" do
        subject
        res = JSON.parse(response.body)

        expect(res["title"]).to eq "タイトル更新"
        expect(res["body"]).to eq "本文更新"
        expect(response).to have_http_status(:ok)
      end
    end

    context "他のユーザーの記事を更新しようとしたとき" do
      # 他人の記事を準備
      let(:article) { create(:article) }

      it "更新失敗すること" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "不適切なパラメータを送信したとき" do
      # 空のデータを送る
      let(:params) { { article: { title: "", body: "" } } }
      # 自分の記事を送る
      let(:article) { create(:article, user: current_user) }

      it "更新に失敗すること" do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /api/v1/articles/:id" do
    subject { delete(api_v1_article_path(article.id)) }

    # paramsは不要 (titleやbodyは準備不要)
    # 「削除」という命令を出すだけで中身を書き換えるわけではないため。
    # let(:article) { create(:article, user: current_user) }←※正常系テストでit文の上に記載するから不要（二重定義になる）
    let(:current_user) { create(:user) }
    before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) }

    context "記事を削除するとき" do
      let!(:article) { create(:article, user: current_user) }

      it "正常に削除できる" do
        expect { subject }.to change { Article.count }.by(-1)
        expect(response).to have_http_status(:ok)
      end
    end

    context "他のユーザーの記事を削除しようとしたとき" do
      # 新しいユーザーを1人作成
      let(:other_user) { create(:user) }
      # 記事の持ち主を user ではなく other_user に指定して作成
      let!(:article) { create(:article, user: other_user) }

      it "削除できないこと" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound) & change { Article.count }.by(0)
      end
    end
  end
end
