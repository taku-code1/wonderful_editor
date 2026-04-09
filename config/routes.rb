Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      mount_devise_token_auth_for "User", at: "auth"

      resources :articles, only: [:index, :show, :create, :update, :destroy] do
        resource :article_like, only: [:create, :destroy]
        resources :comments, only: [:create, :destroy]
      end
    end
  end
end
