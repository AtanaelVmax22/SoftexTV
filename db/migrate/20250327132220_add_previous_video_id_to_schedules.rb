class AddPreviousVideoIdToSchedules < ActiveRecord::Migration[7.0]
  def change
    add_column :schedules, :previous_video_id, :integer
  end
end
