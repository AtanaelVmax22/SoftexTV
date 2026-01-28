class BroadcastsController < ApplicationController
  include Rails.application.routes.url_helpers
  before_action :authenticate_user!
  skip_before_action :verify_authenticity_token
  before_action :set_broadcast, only: [:edit, :update, :destroy]

  def index
    @broadcasts = Broadcast.all
     # Buscar a configuração com id = 1
     streaming_configuration = StreamingConfiguration.find_by(id: 1)

     if streaming_configuration
       server_ip = streaming_configuration.server_ip
       port = streaming_configuration.port
     end
  end

  def new
    @broadcast = Broadcast.new
  end

  def destroy
    @broadcast.destroy
    redirect_to broadcasts_path, notice: 'Broadcast was successfully deleted.'
  end
  def show
    @broadcast = Broadcast.find(params[:id])
  end
   
  def create
    @broadcast = Broadcast.new(broadcast_params)
    streaming_configuration = StreamingConfiguration.find_by(id: 1)
    if streaming_configuration
      server_ip = streaming_configuration.server_ip
      port = streaming_configuration.port
    end
    @stream_url = "http://#{server_ip}:#{port}/hls/stream#{Broadcast.count+1}.m3u8"
  
    # Passar corretamente o parâmetro show_widgets
    if @broadcast.save
      @broadcast.update(
        stream_url:  @stream_url,
        command: @broadcast.generate_command(@broadcast.show_widgets)  # Passando o show_widgets como argumento
      )
      redirect_to broadcasts_path, notice: 'Broadcast was successfully created.'
    else
      render :new
    end
  end
  
  

  def edit
    @broadcast = Broadcast.find(params[:id])
    @schedules = @broadcast.schedules # Carregar os agendamentos vinculados ao Broadcast
    @schedules = @broadcast.schedules.map do |s|
      {
        id: s.id,
        start: s.start_date.strftime('%Y-%m-%d'),
        end: s.end_date.strftime('%Y-%m-%d'),
        video: s.video.attached? ? s.video.filename.to_s : nil # <-- apenas o nome!
      }
    end
    
  end

  def update
    @broadcast = Broadcast.find(params[:id])
  
    if @broadcast.update(broadcast_params)
      @broadcast.update(command: @broadcast.generate_command(@broadcast.show_widgets))

      redirect_to broadcasts_path, notice: 'Broadcast was successfully updated.'
    else
      render :edit
    end
  end
  
  def events
    # Retorna os eventos em formato JSON
    events = Broadcast.all.map do |broadcast|
      {
        title: broadcast.name,
        start: broadcast.event_date.iso8601,
        end: (broadcast.event_date + 1.hour).iso8601
      }
    end
    render json: events
  end

  def update_event
    # Atualiza o evento no banco de dados
    broadcast = Broadcast.find(params[:event_id])
    if broadcast.update(event_date: params[:start])
      render json: { status: 'success' }
    else
      render json: { status: 'error' }
    end
  end

  def stop_all
    broadcasts = Broadcast.where(id: params[:broadcast_ids])

    broadcasts.each do |broadcast|
      if broadcast.process_pid.present? && broadcast.process_pid.to_i > 0
        begin
          if Gem.win_platform?
            # Windows: Usa taskkill para encerrar o processo pelo PID
            system("taskkill /PID #{broadcast.process_pid.to_i} /F")
          else
            # Unix/Linux: Usa sinais TERM e KILL para encerrar o processo
            Process.kill("TERM", broadcast.process_pid.to_i)

            # Espera um curto período para verificar se o processo finalizou
            sleep(2)

            # Força o encerramento se o processo ainda estiver ativo
            if process_alive?(broadcast.process_pid.to_i)
              Process.kill("KILL", broadcast.process_pid.to_i)
            end
          end

          broadcast.update(status: 'stopped', process_pid: nil)
        rescue Errno::ESRCH
          flash[:alert] = "Processo de transmissão não encontrado para o broadcast #{broadcast.name}."
        rescue => e
          flash[:alert] = "Erro ao interromper o broadcast #{broadcast.name}: #{e.message}"
        end
      else
        flash[:alert] = "Nenhum processo ativo encontrado para o broadcast #{broadcast.name}."
      end
    end

    redirect_to broadcasts_path, notice: 'Todas as transmissões foram interrompidas!'
  end
  def start
    @broadcast = Broadcast.find(params[:id])
  
    pid = Process.spawn(@broadcast.command, out: "NUL", err: "NUL")
    Process.detach(pid)
    @broadcast.update(process_pid: pid, status: 'running')
  
    flash[:notice] = "Iniciando broadcast: #{@broadcast.name}"
    redirect_to broadcasts_path
  end
  

  def stop
    @broadcast = Broadcast.find(params[:id])
  
    if @broadcast.process_pid.present? && @broadcast.process_pid.to_i > 0
      begin
        if Gem.win_platform?
          system("taskkill /PID #{@broadcast.process_pid.to_i} /F")
        else
          Process.kill("TERM", @broadcast.process_pid.to_i)
          sleep(2)
          Process.kill("KILL", @broadcast.process_pid.to_i) if process_alive?(@broadcast.process_pid.to_i)
        end
  
        @broadcast.update(status: 'stopped', process_pid: nil)
        flash[:notice] = "Parando broadcast: #{@broadcast.name}"
      rescue => e
        flash[:alert] = "Erro ao parar o broadcast: #{e.message}"
      end
    else
      flash[:alert] = "Nenhum processo ativo encontrado para o broadcast."
    end
  
    redirect_to broadcasts_path
  end
  
  
  def execute
    broadcast_ids = params[:broadcast_ids]

    if broadcast_ids.nil? || broadcast_ids.empty?
      redirect_to broadcasts_path, alert: "Nenhum broadcast selecionado!"
      return
    end

    broadcast_ids.each do |id|
      broadcast = Broadcast.find(id)
      # Use 'NUL' para o Windows
      pid = Process.spawn(broadcast.command, out: "NUL", err: "NUL")
      Process.detach(pid) # Evita processos zumbis
      broadcast.update(process_pid: pid) # Salva o PID
    end

    redirect_to broadcasts_path, notice: 'Commands executed successfully.'
  end

  def export_m3u
    # Pega todos os broadcasts no banco de dados
    broadcasts = Broadcast.all

    if broadcasts.empty?
      redirect_to broadcasts_path, alert: "Nenhum broadcast disponível para exportar!"
      return
    end

    # Gera o conteúdo do arquivo M3U, fazendo a substituição na URL dentro do bloco `map`
    m3u_content = broadcasts.map do |broadcast|
      streaming_configuration = StreamingConfiguration.find_by(id: 1)
    if streaming_configuration
      server_ip = streaming_configuration.server_ip
      port = streaming_configuration.port
    end
    
      # Substitui "localhost" por "192.168.1.253" na URL de stream
      updated_stream_url = broadcast.stream_url.gsub("localhost", "#{server_ip}")

      "#EXTINF:-1,#{broadcast.name}\n#{updated_stream_url}"
    end.join("\n")

    # Envia o conteúdo como um arquivo M3U
    send_data m3u_content, type: 'audio/x-mpegurl', disposition: 'attachment', filename: "broadcasts.m3u"
  end

  private

  def process_alive?(pid)
    begin
      Process.getpgid(pid) # Verifica se o grupo de processos existe
      true
    rescue Errno::ESRCH
      false
    end
  end

  def set_broadcast
    @broadcast = Broadcast.find(params[:id])
  end

def broadcast_params
  params.require(:broadcast).permit(:name, :video, :show_widgets, :event_date, :orientation)
end


  def generate_command(video, stream_url)
    base_command = "ffmpeg -stream_loop -1 -re -i #{video_path} -vf \"scale=768:1366,setdar=9/16,transpose=1,setsar=1\" -c:v libx264 -preset fast -c:a aac -b:a 192k -f flv rtmp://localhost/hls/stream#{Broadcast.count}"
  
    if show_widgets
      base_command = "ffmpeg -stream_loop -1 -re -i C:\\SoftexTV\\softex_tv\\public\\videos\\#{video} -i http://localhost:8080/hls/widgets.m3u8 -filter_complex \"[0:v]scale=768:1366,setdar=9/16,transpose=1,setsar=1[bg];[1:v]scale=768:300,transpose=1,format=yuva420p,colorchannelmixer=aa=0.9[overlay];[bg][overlay]overlay=x=0:y=0\" -c:v libx264 -preset fast -c:a aac -b:a 192k -f flv rtmp://localhost/hls/stream#{Broadcast.count}"
    end
  
    base_command
  end
  
end

class AddProcessPidToBroadcasts < ActiveRecord::Migration[7.0]
  def change
    add_column :broadcasts, :process_pid, :integer
  end
end
