class WidgetsController < ApplicationController
     require 'open3'
    layout false  # Não usa o layout padrão
    def show
    end
    def calendario
       end
      

       def temperature
         script_path = Rails.root.join('app/javascript/fetch_temperature.js')
     
         # Executa o script Node.js para buscar a temperatura
         stdout, stderr, status = Open3.capture3("node #{script_path}")
     
         if status.success?
           render json: { temperature: stdout.strip }
         else
           Rails.logger.error("Erro ao executar script: #{stderr}")
           render json: { temperature: '--' }, status: :internal_server_error
         end
       end
  end
  