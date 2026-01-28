class CreateBroadcasts < ActiveRecord::Migration[7.0]
  def change
    create_table :broadcasts do |t|
      t.string :name
      t.string :video
      t.string :command

      t.timestamps
    end
  end
end
