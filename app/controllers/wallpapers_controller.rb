class WallpapersController < ApplicationController
    def new
      # Carregar a página do formulário
    end
  
    def create
      wallpaper = params[:wallpaper] # O arquivo enviado
  
      # Verifique se há um arquivo
      if wallpaper
        # Gera o nome do arquivo e salva no diretório public/wallpapers
        file_path = Rails.root.join('public', 'wallpapers', "wallpaper.jpeg")
  
        # Salve o arquivo
        File.open(file_path, 'wb') do |file|
          file.write(wallpaper.read)
        end
  
        # Redireciona ou exibe uma mensagem de sucesso
      
      else
        #render :new, alert: "Erro ao carregar o wallpaper."
      end
    end
  
    def index
      # Exibe os wallpapers disponíveis
      @wallpapers = Dir[Rails.root.join('public', 'wallpapers', '*')]
    end
  end
  