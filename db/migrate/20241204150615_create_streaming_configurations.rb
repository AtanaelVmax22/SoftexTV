class CreateStreamingConfigurations < ActiveRecord::Migration[7.0]
  def change
    create_table :streaming_configurations do |t|
      t.string :server_ip, null: false
      t.integer :port, default: 8080  
      t.string :server_name, default: 'SoftexTv'
      

      t.timestamps
    end
  end
end
