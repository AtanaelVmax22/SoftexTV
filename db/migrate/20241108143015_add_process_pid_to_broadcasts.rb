class AddProcessPidToBroadcasts < ActiveRecord::Migration[7.0]
  def change
    add_column :broadcasts, :process_pid, :integer
  end
end
