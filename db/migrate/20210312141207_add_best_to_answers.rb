class AddBestToAnswers < ActiveRecord::Migration[6.1]
  def change
    add_column :answers, :best, :boolean, null: false, default: false
  end
end
