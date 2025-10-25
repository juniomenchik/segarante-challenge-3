Rails.application.routes.draw do
  get '/csrf', to: 'application#csrf'

  get '/apolices/endossos/:endosso_id', to: 'apolices#endossos_show'

  resources :apolices, only: [:create, :show, :index], param: :id do
    member do
      get  'endossos',             to: 'apolices#endossos_index'
      post 'endossos',             to: 'apolices#endossos_create'
    end
  end
end
