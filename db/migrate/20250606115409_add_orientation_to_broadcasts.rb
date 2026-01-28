class AddOrientationToBroadcasts < ActiveRecord::Migration[7.0]
  def change
    add_column :broadcasts, :orientation, :string
  end
end
