#!/usr/bin/env bash
# exit on error
set -o errexit

yarn install --check-files
bundle install
bundle exec rails webpacker:compile
bundle exec rake assets:precompile
bundle exec rake assets:clean
bundle exec rake db:migrate
