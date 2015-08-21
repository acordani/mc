Rails.application.routes.draw do
  get 'cocktails' => "cocktails#index"

  get 'cocktails/:id' => "cocktails#show"

  get 'cocktails/new' => "cocktails#new"

  post 'cocktails' => "cocktails#create"

  resources :cocktails, only: [:index,:new, :show, :create] do
    resources :doses, only: [:new, :create]
  end
  resources :doses,only: [:destroy]
end
