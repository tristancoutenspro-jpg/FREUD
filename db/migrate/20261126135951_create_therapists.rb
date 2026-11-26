class CreateTherapists < ActiveRecord::Migration[8.1]
  def change
    create_table :therapists do |t|
      t.string :name
      t.text :prompt

      t.timestamps
    end
  end
end
