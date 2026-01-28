class CreateLicenses < ActiveRecord::Migration[7.0]
  def change
    create_table :licenses do |t|
      t.string :token
      t.date :valid_until

      t.timestamps
    end
  end
end
