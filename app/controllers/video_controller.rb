class VideoController < ApplicationController
  def start
    command = params[:video][:command] # Captura 'start' ou 'stop'

    if command == 'start'
      start_overlay_script
      render json: { message: 'Processo iniciado com sucesso!' }, status: :ok
    elsif command == 'stop'
      stop_overlay_script
      render json: { message: 'Processo parado com sucesso!' }, status: :ok
    else
      render json: { error: 'Comando inválido. Use "start" ou "stop".' }, status: :unprocessable_entity
    end
  end
end
