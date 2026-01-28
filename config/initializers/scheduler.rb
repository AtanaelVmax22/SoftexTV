require 'rufus-scheduler'

return unless Rails.env.development? || Rails.env.production?

scheduler = Rufus::Scheduler.new

scheduler.every '1m' do
  Rails.logger.info "[Scheduler] Verificando agendamentos..."
  ScheduleUpdater.run
end
