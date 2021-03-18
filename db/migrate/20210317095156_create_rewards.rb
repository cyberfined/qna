class CreateRewards < ActiveRecord::Migration[6.1]
  def change
    create_table :rewards do |t|
      t.string :title, null: false
      t.references :question, null: false, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
