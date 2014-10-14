class CreateArticels < ActiveRecord::Migration
  def change
    create_table :articels do |t|
      t.string :desc

      t.timestamps
    end
  end
end
