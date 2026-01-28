class AddAppliedToSchedules < ActiveRecord::Migration[7.0]
  def change
    add_column :schedules, :applied, :boolean, default: false
  end
end
