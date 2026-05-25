FROM ruby:3.1.3

# Node.js 20をインストールしてPython2を入れる（ビルドを通すための魔法）
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs python2 && \
    ln -s /usr/bin/python2 /usr/bin/python && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn

WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
RUN gem install rails -v 6.1.7.10 && bundle install

COPY . /myapp

# ここでアセットをコンパイルする
RUN bundle exec rails assets:precompile
