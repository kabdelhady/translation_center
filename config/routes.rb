TranslationCenter::Engine.routes.draw do
  
  resources :translations do
    post :vote
    post :unvote
    post :accept
    post :unaccept
  end

  resources :translation_keys do
    post :update_translation
    get :translations
  end

  resources :categories  do
    get :more_keys
  end

  root to: 'categories#index'

  # set the language from and to for the user
  post "/set_language_from" => 'center#set_language_from', as: :set_lang_from
  post "/set_language_to" => 'center#set_language_to', as: :set_lang_to
end
