# 使用するrubyのイメージ
FROM ruby:3.1.3

# RUBYGEMS_VERSIONを引数として設定
ARG RUBYGEMS_VERSION=3.3.20

# PostgreSQLクライアントをインストール
RUN apt-get update -qq && apt-get install -y postgresql-client nano

# アプリケーションディレクトリを作成
RUN mkdir /backend
WORKDIR /backend

# Gemをインストール
COPY Gemfile /backend/Gemfile
COPY Gemfile.lock /backend/Gemfile.lock
RUN gem install bundler
RUN gem update --system ${RUBYGEMS_VERSION} && bundle install

# アプリケーションのソースをコピー
COPY . /backend

# Rails固有のエントリーポイント対応
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Railsサーバーの起動
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
