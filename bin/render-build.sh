#!/usr/bin/env bash
# exit on error
set -o errexit

# ① 依存パッケージを完全に本番環境へインストール
yarn install --production=false

# ② Rubyのセットアップ
bundle install

# ③ Vue（Webpack）を確実に本番用にビルドする
bundle exec rails webpacker:compile

# ④ Railsのアセットをコンパイル
bundle exec rails assets:precompile
bundle exec rails assets:clean

# ⑤ データベースのマイグレーション
bundle exec rails db:migrate
