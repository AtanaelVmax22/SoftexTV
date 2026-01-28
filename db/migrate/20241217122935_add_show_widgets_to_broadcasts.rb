class AddShowWidgetsToBroadcasts < ActiveRecord::Migration[7.0]
  def change
    add_column :broadcasts, :show_widgets, :boolean, default: false, null: false
  end
end
