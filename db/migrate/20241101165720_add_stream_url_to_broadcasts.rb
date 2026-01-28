class AddStreamUrlToBroadcasts < ActiveRecord::Migration[7.0]
  def change
    add_column :broadcasts, :stream_url, :string
  end
end
