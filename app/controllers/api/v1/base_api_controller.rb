class Api::V1::BaseApiController < ApplicationController
  # ここに v1 の API 全体で使いたい共通設定を書く。
  # データベースの最初の一人目を「今のログインユーザー」と見なす設定
  def current_user
    @current_user ||= User.first
  end
end
