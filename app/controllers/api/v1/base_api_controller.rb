class Api::V1::BaseApiController < ApplicationController
  # ここに v1 の API 全体で使いたい共通設定を書く。
  # これを追加することで、current_user や authenticate_user! が使えるようになる
  include DeviseTokenAuth::Concerns::SetUserByToken

  alias_method :current_user, :current_api_v1_user
  alias_method :authenticate_user!, :authenticate_api_v1_user!
  alias_method :user_signed_in?, :api_v1_user_signed_in?
end
