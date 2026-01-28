class AddStatusToBroadcasts < ActiveRecord::Migration[7.0]
  def change
    add_column :broadcasts, :status, :string, default: 'stopped'
  end
end
