require "rails_helper"
# index開始
# --------------------------------------------------------------------------------
RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET /api/v1/articles" do
    # 【共通設定】テスト対象のURL
    subject { get(api_v1_articles_path) }

    # 並び順をテストする際は、比較対象のデータが必要
    let!(:article1) { create(:article, :published, updated_at: 1.days.ago) }
    let!(:article2) { create(:article, :published, updated_at: 2.days.ago) }
    let!(:article3) { create(:article, :published) }

    # コントローラーでstatusが公開のものしか通さないフィルターをかけた。下書き記事は通さない証明となる。
    before { create(:article, :draft) }

    it "記事一覧を取得できること" do
      subject
      res = JSON.parse(response.body)

      expect(response).to have_http_status(:ok) # ステータスコードは200であること
      expect(res.length).to eq 3
      expect(res.map {|d| d["id"] }).to eq [article3.id, article1.id, article2.id]
      expect(res[0].keys).to eq ["id", "title", "updated_at", "user"]
      expect(res[0].keys).not_to include("body")
      expect(res[0]["user"].keys).to eq ["id", "name", "email"]
    end
  end
  # --------------------------------------------------------------------------------
  # index終了

  describe "GET /api/v1/articles/:id" do
    subject { get(api_v1_article_path(article_id)) }

    context "指定したidの記事が存在して" do
      let(:article_id) { article.id }

      context "その記事が公開中である場合" do
        let(:article) { create(:article, :published) }

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

      context "その記事が下書きである場合" do
        let(:article) { create(:article, :draft) }

        it "記事が見つからない" do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
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
    subject { post(api_v1_articles_path, params: params, headers: headers) }

    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }

    context "公開を指定して記事作成するとき" do
      let(:params) { { article: attributes_for(:article, :published) } }

      it "記事のレコードが作成できる" do
        expect { subject }.to change { Article.where(user_id: current_user.id).count }.by(1)
        res = JSON.parse(response.body)
        expect(res["title"]).to eq params[:article][:title]
        expect(res["body"]).to eq params[:article][:body]
        expect(res["status"]).to eq "published"
        expect(response).to have_http_status(:ok)
      end
    end

    context "下書きを指定して記事作成するとき" do
      let(:params) { { article: attributes_for(:article, :draft) } }

      it "下書き記事を作成できる" do
        expect { subject }.to change { Article.where(user_id: current_user.id).count }.by(1)
        res = JSON.parse(response.body)
        expect(res["title"]).to eq params[:article][:title]
        expect(res["body"]).to eq params[:article][:body]
        expect(res["status"]).to eq "draft"
        expect(response).to have_http_status(:ok)
      end
    end

    context "不適切なパラメーターを送信したとき" do
      # 空のデータを送る
      let(:params) { { article: { title: "", body: "" } } }

      it "記事の作成に失敗する" do
        expect { subject }.not_to change { Article.count }
        expect(response).to have_http_status(:unprocessable_entity) # 422エラーが返るか
      end
    end

    context "でたらめな指定で記事を作成するとき" do
      let(:params) { { article: attributes_for(:article, status: :foo) } }

      it "エラーになる" do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end

  describe "PATCH /api/v1/articles/:id" do
    subject { patch(api_v1_article_path(article.id), params: params, headers: headers) }

    let(:params) { { article: attributes_for(:article, :published) } }
    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }

    context "自分の下書き記事を更新するとき" do
      # 自分の記事を準備
      let!(:article) { create(:article, :draft, user: current_user) }

      it "正常に更新できる" do
        expect { subject }.to change { article.reload.title }.from(article.title).to(params[:article][:title]) &
                              change { article.reload.body }.from(article.body).to(params[:article][:body]) &
                              change { article.reload.status }.from(article.status).to(params[:article][:status].to_s)
        expect(response).to have_http_status(:ok)
      end
    end

    context "他のユーザーの記事を更新しようとしたとき" do
      # 他人の記事を準備
      let(:other_user) { create(:user) }
      # その「他人」を作者にして記事を作成
      let!(:article) { create(:article, user: other_user) }

      it "更新失敗すること" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "不適切なパラメータを送信したとき" do
      # 空のデータを用意
      let(:params) { { article: { title: "", body: "" } } }
      # 自分の記事を用意
      let(:article) { create(:article, user: current_user) }

      it "更新に失敗すること" do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /api/v1/articles/:id" do
    subject { delete(api_v1_article_path(article_id), headers: headers) }

    # paramsは不要 (titleやbodyは準備不要)
    # 「削除」という命令を出すだけで中身を書き換えるわけではないため。
    # let(:article) { create(:article, user: current_user) }←※正常系テストでit文の上に記載するから不要（二重定義になる）
    let(:current_user) { create(:user) }
    # 記事からidだけを控えたメモ。記事を消してもメモは残るから「どの記事消したんだっけ？」とならずに済む。
    let(:article_id) { article.id }
    let(:headers) { current_user.create_new_auth_token }

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
