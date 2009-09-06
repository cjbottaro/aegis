class CreateForums < ActiveRecord::Migration
  def self.up
    create_table :forums do |t|
      t.integer :account_id, :null => false
      t.string  :name,       :null => false
    end
  end

  def self.down
    drop_table :forums
  end
end
