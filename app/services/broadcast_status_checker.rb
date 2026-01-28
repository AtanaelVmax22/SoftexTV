class BroadcastStatusChecker
    def self.verify_all
      Broadcast.where(status: 'running').find_each do |broadcast|
        if broadcast.process_pid.nil? || !process_alive?(broadcast.process_pid)
          Rails.logger.info "Broadcast #{broadcast.id} estava como 'running', mas o processo não existe. Reiniciando..."
  
          # Reinicia o processo
          pid = spawn_hidden(broadcast.command)
          Process.detach(pid)
  
          broadcast.update(process_pid: pid, status: 'running')
  
          Rails.logger.info "Broadcast #{broadcast.id} reiniciado com novo PID #{pid}"
        end
      end
    end
  
    def self.process_alive?(pid)
      pid = pid.to_i
      if Gem.win_platform?
        output = `tasklist /FI "PID eq #{pid}"`
        !output.include?("Nenhum processo") && output.include?(pid.to_s)
      else
        Process.getpgid(pid)
        true
      end
    rescue Errno::ESRCH, NotImplementedError
      false
    end
  
    def self.spawn_hidden(command)
      if Gem.win_platform?
        Process.spawn(command, out: 'NUL', err: 'NUL')
      else
        Process.spawn(command, out: '/dev/null', err: '/dev/null')
      end
    end
  end
  