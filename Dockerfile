FROM ruby:3.1.3

# 必要なOSライブラリのみインストール
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y yarn

WORKDIR /myapp

# Gemfileだけコピーし、コンテナ内部だけで独立してインストール
COPY Gemfile /myapp/Gemfile
RUN gem install rails -v 6.1.7.10 && bundle install

# 最後にファイルをコピー
COPY . /myapp
