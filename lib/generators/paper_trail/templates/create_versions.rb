class CreateVersions < ActiveRecord::Migration
  def self.up
    create_table :versions do |t|
      t.string   :item_type, :null => false
      t.integer  :item_id,   :null => false
      t.string   :event,     :null => false
      t.string   :whodunnit
      t.text     :object
      t.integer  :transaction_id
      t.datetime :created_at
    end
    add_index :versions, [:item_type, :item_id]
    add_index :versions, [:transaction_id]
  end

  def self.down
    remove_index :versions, [:item_type, :item_id]
    remove_index :versions, [:transaction_id]
    drop_table :versions
  end
end
