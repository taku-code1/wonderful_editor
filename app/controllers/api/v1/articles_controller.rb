class Api::V1::ArticlesController < Api::V1::BaseApiController
  # ↓ この一行が「誰でもみれるようにする」ための設定。
  skip_before_action :authenticate_user!, only: [:index], raise: false

  def index
    articles = Article.order(updated_at: :desc)
    render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
  end

  def show
    article = Article.find(params[:id])
    render json: article, serializer: Api::V1::ArticleSerializer
  end

  def create
    # ログインユーザーに関連付けて記事を作成
    article = current_user.articles.build(article_params)

    if article.save
      # 成功時：保存されたデータをJSONで返す
      render json: article, serializer: Api::V1::ArticleSerializer
    else
      # 失敗時：バリデーションエラーの内容を返す（status: 422）
      render json: article.errors, status: :unprocessable_entity
    end
  end

  def update
    # 「ログイン中のあなた」の「記事」の中から「指定されたID」を探す
    article = current_user.articles.find(params[:id])

    # 見つかった記事を更新する
    if article.update(article_params)
      render json: article, serializer: Api::V1::ArticleSerializer

    # 記事は見つかったが、保存に失敗した場合
    else
      render json: article.errors, status: :unprocessable_entity
    end
  end

  def destroy
    article = current_user.articles.find(params[:id])
    article.destroy!
    render json: article
  end

  private

  # 許可するパラメーターを制限（ストロングパラメーター）
  def article_params
    params.require(:article).permit(:title, :body)
  end
end
