class AddUniqueIndexToArticleLikes < ActiveRecord::Migration[6.1]
  def change
    # user_id と article_id の組み合わせをユニーク（一意）にする
    add_index :article_likes, [:user_id, :article_id], unique: true
  end
end
