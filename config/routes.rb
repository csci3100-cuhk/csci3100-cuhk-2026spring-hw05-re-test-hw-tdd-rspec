Rottenpotatoes::Application.routes.draw do
  resources :movies
  get 'movies/:id/similar', to: 'movies#show_by_director', as: 'same_director'
  # map '/' to be a redirect to '/movies'
  root to: redirect('/movies')
end
