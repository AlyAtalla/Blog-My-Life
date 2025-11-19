class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.integer :sender_id, null: false
      t.integer :recipient_id, null: false
      t.text :body, null: false
      t.datetime :read_at

      t.timestamps
    end

    add_index :messages, :sender_id
    add_index :messages, :recipient_id
    add_index :messages, [:recipient_id, :read_at]
  end
end
