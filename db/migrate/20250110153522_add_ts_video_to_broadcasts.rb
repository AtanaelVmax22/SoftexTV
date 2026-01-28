class AddTsVideoToBroadcasts < ActiveRecord::Migration[7.0]
  def change
    add_column :broadcasts, :ts_video, :binary
  end
end
