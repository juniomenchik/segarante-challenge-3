Rails.application.routes.draw do
  get '/csrf', to: 'application#csrf'
  resources :apolices, only: [:create, :show, :index], param: :id do
    member do
      get  'endossos',             to: 'apolices#endossos_index'
      post 'endossos',             to: 'apolices#endossos_create'
      get  'endossos/:endosso_id', to: 'apolices#endossos_show'
    end
  end
end
