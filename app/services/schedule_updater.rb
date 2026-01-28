class ScheduleUpdater
  def self.run
    now = Time.zone.now

    # 1. Aplica os agendamentos atuais
    Schedule.includes(:broadcast)
      .active_now(now)
      .where(applied: false)
      .find_each do |schedule|

      broadcast = schedule.broadcast

      unless broadcast.status == "running"
        Rails.logger.info "Broadcast #{broadcast.id} está parado. Ignorando agendamento #{schedule.id}."
        next
      end

      if schedule.video.attached?
        if broadcast.video.attached?
          schedule.update!(previous_video_id: broadcast.video.blob.id)
          broadcast.video.detach
        end

        broadcast.video.attach(schedule.video.blob)
      end

      if broadcast.process_pid.present?
        begin
          Process.kill("KILL", broadcast.process_pid)
        rescue => e
          Rails.logger.warn "Erro ao encerrar processo PID #{broadcast.process_pid}: #{e.message}"
        end
      end

      new_command = broadcast.generate_command(broadcast.show_widgets)
      broadcast.update!(command: new_command)

      pid = spawn_hidden(new_command)
      Process.detach(pid)
      broadcast.update!(process_pid: pid)

      schedule.update!(applied: true)

      Rails.logger.info "Broadcast #{broadcast.id} reiniciado com vídeo do agendamento #{schedule.id}"
    end

    # 2. Restaura vídeos antigos após o fim do agendamento
    Schedule.includes(:broadcast)
      .where('end_date < ?', now)
      .where(applied: true)
      .find_each do |expired_schedule|

      broadcast = expired_schedule.broadcast

      if expired_schedule.previous_video_id.present?
        begin
          previous_blob = ActiveStorage::Blob.find(expired_schedule.previous_video_id)

          broadcast.video.detach if broadcast.video.attached?
          broadcast.video.attach(previous_blob)

          # Reinicia processo com vídeo anterior
          if broadcast.process_pid.present?
            begin
              Process.kill("KILL", broadcast.process_pid)
            rescue => e
              Rails.logger.warn "Erro ao encerrar processo PID #{broadcast.process_pid}: #{e.message}"
            end
          end

          new_command = broadcast.generate_command(broadcast.show_widgets)
          broadcast.update!(command: new_command)

          pid = spawn_hidden(new_command)
          Process.detach(pid)
          broadcast.update!(process_pid: pid)

          Rails.logger.info "Broadcast #{broadcast.id} restaurado com vídeo anterior após agendamento #{expired_schedule.id}"
        rescue => e
          Rails.logger.error "Erro ao restaurar vídeo anterior do agendamento #{expired_schedule.id}: #{e.message}"
        end
      end

      expired_schedule.update!(applied: false)
    end
  end

  def self.spawn_hidden(command)
    if Gem.win_platform?
      Process.spawn(command, out: 'NUL', err: 'NUL')
    else
      Process.spawn(command, out: '/dev/null', err: '/dev/null')
    end
  end
end
