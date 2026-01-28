Rails.application.routes.draw do
 
 
  devise_for :users, skip: [:registrations]
  get '/licenca_invalida', to: 'pages#licenca_invalida', as: :licenca_invalida
  get  '/licenca', to: 'license#new'
  post '/licenca', to: 'license#create'
  
  as :user do
    get 'users/edit' => 'devise/registrations#edit', as: :edit_user_registration
    put 'users' => 'devise/registrations#update', as: :user_registration
  end
  resources :users

  # Configuração das transmissões (broadcasts)
  resources :broadcasts do
    member do
      post 'start'
      post 'stop'
    end
    collection do
      post 'execute'
      post 'stop_all'
      post :set_wallpaper
    end
  end
  
  # Rota para executar os broadcasts selecionados (botão "Play All Selected")
  post 'execute_broadcasts', to: 'broadcasts#execute'
  
  # Rota para exportar o arquivo M3U
  get 'export_m3u_broadcasts', to: 'broadcasts#export_m3u'

  # Configuração das transmissões de streaming
  resources :streaming_configurations do
    member do
      post 'start_streaming'
      post 'stop_streaming'
    end
  end
# config/routes.rb

resources :schedules, only: [:index, :create] do
  collection do
    post 'bulk_create' # Adicionando a rota para salvar múltiplos períodos
    delete :destroy_schedule
  end
end
  # Configuração das rotas para wallpapers
  resources :wallpapers, only: [:new, :create, :index] do
    post 'update_wallpaper', on: :collection
  end

  # Rota para mudar o idioma
  get 'change_locale', to: 'application#change_locale', as: 'change_locale'

  # Recursos adicionais
  get 'widgets', to: 'widgets#show'
  get 'widgets/calendario', to: 'widgets#calendario'
  get 'widgets/clima', to: 'widgets#clima'
  get '/temperature', to: 'widgets#temperature'

  
  # Rota para iniciar e parar o vídeo
  post 'video/start', to: 'video#start'
  post 'video/stop', to: 'video#stop'

  # Rota raiz
  root 'broadcasts#index'
end
