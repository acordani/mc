Rails.application.routes.draw do
  get 'cocktails/index'

  get 'cocktails/show'

  get 'cocktails/new'

  get 'cocktails/create'

  resources :cocktails, only: [:index,:new, :show, :create] do
    resources :doses, only: [:new, :create]
  end
  resources :doses,only: [:destroy]
end
