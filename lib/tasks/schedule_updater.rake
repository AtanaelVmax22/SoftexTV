# lib/tasks/schedule_updater.rake
namespace :schedule do
    desc "Atualiza os vídeos dos broadcasts de acordo com os agendamentos do dia"
    task update_broadcasts: :environment do
      ScheduleUpdater.run
    end
  end
  