class AddWidgetsToStreamingConfigurations < ActiveRecord::Migration[7.0]
  def change
    add_column :streaming_configurations, :widgets, :boolean, default: false
  end
end
