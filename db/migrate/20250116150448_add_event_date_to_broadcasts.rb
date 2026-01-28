class AddEventDateToBroadcasts < ActiveRecord::Migration[7.0]
  def change
    add_column :broadcasts, :event_date, :datetime
  end
end
