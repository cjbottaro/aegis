module Aegis
  class RoleAssignment < ActiveRecord::Base
    belongs_to :actor, :polymorphic => true
    belongs_to :context, :polymorphic => true
    
    def context_key
      "#{context.class}:#{context.id}"
    end
  end
end