# frozen_string_literal: true

Rails.application.routes.draw do
  root "home#index"
  get "/categories/:id", to: "home#show"

  namespace :admin do
    get "/dashboard", to: "dashboard#index"
    resource :crawlers, only: %i(create destroy)
    resources :crawler_questions, only: %i(index create update destroy)
    resources :crawler_answers, only: %i(create update destroy)
    resources :categories, except: %i(new edit)
  end

  namespace :api do
    namespace :v1 do
      resources :exams, only: [:index, :create, :destroy, :show]
    end
  end

  devise_for :users
  resources :questions do
    resources :rollback_questions, only: :index
  end
  resources :exams
  mount ActionCable.server => '/cable'
  resources :categories, only: [:show]
end
