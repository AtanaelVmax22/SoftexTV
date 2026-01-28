class AddWallpaperToBroadcasts < ActiveRecord::Migration[7.0]
  def change
    add_column :broadcasts, :wallpaper, :string
  end
end
