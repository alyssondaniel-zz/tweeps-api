Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      get '/most_relevants' => 'tweeps#most_relevants', as: :most_relevants
      get '/most_mentions' => 'tweeps#most_mentions', as: :most_mentions
    end
  end
end
