# app/controllers/schedules_controller.rb
class SchedulesController < ApplicationController
  #before_action :ensure_json_request

  rescue_from StandardError do |exception|
    Rails.logger.error("Erro inesperado: #{exception.message}")
    render json: { error: "Erro interno no servidor: #{exception.message}" }, status: 500
  end

  def bulk_create
    if params[:schedules].present?
      if params[:removed_ids].present?
        Schedule.where(id: params[:removed_ids]).destroy_all
      end
  
      params[:schedules].each do |_, schedule_data|
        start_date = Date.strptime(schedule_data[:start_date], '%Y-%m-%d')
        end_date = Date.strptime(schedule_data[:end_date], '%Y-%m-%d')
        video_file = schedule_data[:video]
        broadcast_id = schedule_data[:broadcast_id]
  
        next if video_file.nil?
  
        schedule = Schedule.new(
          start_date: start_date,
          end_date: end_date,
          broadcast_id: broadcast_id,
          applied: false
        )
  
        schedule.video.attach(video_file)
        schedule.save!
      end
  
      head :ok
    else
      head :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Erro inesperado no bulk_create: #{e.message}\n#{e.backtrace.join("\n")}"
    head :internal_server_error
  end
  
  
  

  def index
    @schedules = Schedule.all.map do |s|
      {
        id: s.id,
        title: s.video,
        start: s.start_date.strftime('%Y-%m-%d'),
        end: s.end_date.strftime('%Y-%m-%d')
      }
    end

    render json: @schedules
  end

  def create
    @schedule = Schedule.new(schedule_params.merge(applied: false))
  
    if @schedule.save
      render json: @schedule, status: :created
    else
      render json: @schedule.errors, status: :unprocessable_entity
    end
  end
  

  def destroy_schedule
    schedule = Schedule.find_by(id: params[:id])

    if schedule&.destroy
      render json: { message: "Removido com sucesso" }, status: :ok
    else
      render json: { error: "Erro ao remover o agendamento" }, status: :unprocessable_entity
    end
  end

  private

  def schedule_params
    params.require(:schedule).permit(:start_date, :end_date, :video, :broadcast_id)
  end

  def ensure_json_request
    return if request.format.json? || request.content_type =~ /multipart\/form-data/
    render plain: "Formato não suportado", status: 406
  end
  
  
end
