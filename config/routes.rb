Rails.application.routes.draw do
  get '/csrf', to: 'application#csrf'

  resources :apolices, only: [:create, :index, :show] do
    # custom actions mapeando nomes existentes no controller
    member do
      post 'endossos', to: 'apolices#endossos_create'
      get  'endossos', to: 'apolices#endossos_index'
      get  'endossos/:endosso_id', to: 'apolices#endossos_show'
    end
  end
end


