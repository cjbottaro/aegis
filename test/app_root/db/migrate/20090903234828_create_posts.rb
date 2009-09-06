class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.integer :forum_id, :null => false
      t.string  :title,    :null => false
    end
  end

  def self.down
    drop_table :posts
  end
end
