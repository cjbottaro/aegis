class CreateRoleAssignments < ActiveRecord::Migration
  def self.up
    create_table :role_assignments do |t|
      t.string  :actor_type,    :null => false
      t.integer :actor_id,      :null => false
      t.string  :role_name,     :null => false
      t.string  :context_type,  :null => false
      t.integer :context_id,    :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :role_assignments
  end
end
