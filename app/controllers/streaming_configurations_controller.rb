class StreamingConfigurationsController < ApplicationController
  layout 'empty', only: [:edit, :new]  # Define o layout para as ações 'edit' e 'new'
  before_action :set_streaming_configuration, only: %i[show edit update destroy]

  def update
    previous_widgets_state = @streaming_configuration.widgets

    respond_to do |format|
      if @streaming_configuration.update(streaming_configuration_params)
        Rails.logger.info "Widgets antes: #{previous_widgets_state}, agora: #{@streaming_configuration.widgets}"

        # Se o checkbox foi marcado (widgets = true) e o estado anterior era false
        if @streaming_configuration.widgets && !previous_widgets_state
          start_overlay_script # Iniciar o script generate_overlay.js
        # Se o checkbox foi desmarcado (widgets = false) e o estado anterior era true
        elsif !@streaming_configuration.widgets && previous_widgets_state
          stop_overlay_script # Parar o script
        end

        format.html { redirect_to broadcasts_path, notice: "Configuração atualizada com sucesso." }

        format.json { render :show, status: :ok, location: @streaming_configuration }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @streaming_configuration.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def start_overlay_script
    command = "start /B /MIN node app/javascript/generate_overlay.js start"  # Comando a ser executado no Windows

    begin
      system(command)  # Executa o comando sem abrir uma nova janela visível
      Rails.logger.info "Processo iniciado com comando: #{command}"
    rescue => e
      Rails.logger.error "Erro ao iniciar o processo: #{e.message}"
    end
  end

  def stop_overlay_script
    # Executa o comando para parar o overlay antes de matar o processo
    command = "start /B /MIN node app/javascript/generate_overlay.js stop"
    begin
      system(command)  # Executa o comando stop
      Rails.logger.info "Comando para parar o overlay executado com sucesso."

      # Agora, se houver um processo ativo, encerre-o
      if @streaming_configuration.pid
        # No Windows, podemos usar o comando 'taskkill' para matar o processo
        system("taskkill /PID #{@streaming_configuration.pid} /F")
        Rails.logger.info "Processo com PID #{@streaming_configuration.pid} encerrado com sucesso."
        @streaming_configuration.update(pid: nil) # Limpa o PID após encerrar o processo
      else
        Rails.logger.warn "Nenhum processo ativo encontrado para encerrar."
      end
    rescue => e
      Rails.logger.error "Erro ao parar o processo de overlay: #{e.message}"
    end
  end

  def set_streaming_configuration
    @streaming_configuration = StreamingConfiguration.find(params[:id])
  end

  def streaming_configuration_params
    params.require(:streaming_configuration).permit(:widgets, :server_ip, :port, :server_name, :pid)
  end
end
