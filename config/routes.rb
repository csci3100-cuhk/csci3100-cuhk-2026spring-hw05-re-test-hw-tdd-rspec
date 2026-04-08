Rottenpotatoes::Application.routes.draw do
  resources :movies
  # TODO(hw05-director): add a route for "find movies with same director".
  # map '/' to be a redirect to '/movies'
  root to: redirect('/movies')
end
