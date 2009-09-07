module Aegis
  module HasRole
    
    def self.extended(mod)
      mod.send(:extend,  ClassMethods)
    end
    
    module ClassMethods
    
      def validates_role_name(options = {})
        validates_each :role_name do |record, attr, value|
          options[:message] ||= ActiveRecord::Errors.default_error_messages[:inclusion]
          role = ::Permissions.find_role_by_name(value)
          record.errors.add attr, options[:message] if role.nil?
        end
      end
      
      alias_method :validates_role, :validates_role_name
      
      def has_role(options = {})
        
        if options[:name_accessor]
          options[:name_reader] = "#{options[:name_accessor]}"
          options[:name_writer] = "#{options[:name_accessor]}="
          options.delete(:name_accessor)
        end
        
        @aegis_role_name_reader        = (options[:name_reader] || "role_name").to_sym
        @aegis_role_name_writer        = (options[:name_writer] || "role_name=").to_sym
        @aegis_role_hierarchy          = (options[:hierarchy]   || {})
        @aegis_role_hierarchy_accessor = (options[:hierarchy_accessor])
        @aegis_forced_roles            = options.inject({}) do |memo, (k, v)|
          (m = k.to_s.match(/force_(.+)_if/)) and (memo[v] = m[1])
          memo
        end
        
        meta_eval do
          attr_reader :aegis_role_name_reader
          attr_reader :aegis_role_name_writer
          attr_reader :aegis_role_hierarchy
          attr_reader :aegis_role_hierarchy_accessor
          attr_reader :aegis_forced_roles
        end
        
        has_many :role_assignments, :class_name  => "Aegis::RoleAssignment",
                                    :as          => "actor"
        
        attr_writer :role_assignments_override
        
        include(InstanceMethods)
        
        alias_method_chain :method_missing, :aegis_permissions
      end
      
      alias_method :has_roles, :has_role
      
    end # module ClassMethods
    
    module InstanceMethods
        
      def aegis_role_name_reader
        self.class.aegis_role_name_reader
      end

      def aegis_role_name_writer
        self.class.aegis_role_name_writer
      end
      
      def aegis_role_hierarchy
        self.class.aegis_role_hierarchy
      end
      
      def aegis_role_hierarchy_accessor
        self.class.aegis_role_hierarchy_accessor
      end
      
      def aegis_forced_roles
        self.class.aegis_forced_roles
      end

      def aegis_role_name
        send(aegis_role_name_reader)
      end

      def aegis_role_name=(value)
        send(aegis_role_name_writer, value)
      end

      def role
        (forced_role = role_forced) and return forced_role
        ::Permissions.find_role_by_name!(aegis_role_name)
      end
      
      def role=(role_or_name)
        self.aegis_role_name = if role_or_name.is_a?(Aegis::Role)
          role_or_name.name
        else
          role_or_name.to_s
        end
      end
      
      def role_in(context, tried_contexts = [])
        (forced_role = role_forced) and return forced_role
        context_key = "#{context.class}:#{context.id}"
        tried_contexts << context_key
        roles_by_context = role_assignments_hash
        if roles_by_context.has_key?(context_key)
          ::Permissions.find_role_by_name!(roles_by_context[context_key])
        elsif !aegis_role_hierarchy.blank? and (parent_class_accessor = aegis_role_hierarchy[context.class.name])
          role_in(context.send(parent_class_accessor), tried_contexts)
        elsif aegis_role_hierarchy_accessor and context.respond_to?(aegis_role_hierarchy_accessor)
          role_in(context.send(aegis_role_hierarchy_accessor), tried_contexts)
        else
          actor_key = "#{self.class}:#{self.id}"
          tried_contexts = tried_contexts.join(", ")
          raise Aegis::PermissionError, "cannot find role for #{actor_key} in #{tried_contexts}"
        end
      end
      
      def role_assignments_hash(*args)
        return @role_assignments_override unless @role_assignments_override.blank?
        role_assignments.inject({}) do |memo, role_assignment|
          memo[role_assignment.context_key] = role_assignment.role_name
          memo
        end
      end
      
      def role_forced
        aegis_forced_roles.each do |proc, role_name|
          return role_name if proc.call(self)
        end
        nil
      end
        
    private
    
      # Delegate may_...? and may_...! methods to the user's role.
      def method_missing_with_aegis_permissions(symb, *args)
        method_name = symb.to_s
        if method_name =~ /^may_(.+?)_in[\!\?]$/
          #method_name = method_name[0...-4] + method_name[-1, 1] # may_edit_post_in? => may_edit_post?
          role_in(args.first).send(method_name, self, *args)
        elsif method_name =~ /^may_(.+?)[\!\?]$/
          role.send(symb, self, *args)
        elsif method_name =~ /^(.*?)\?$/ && queried_role = ::Permissions.find_role_by_name($1)
          role == queried_role
        else
          method_missing_without_aegis_permissions(symb, *args)
        end
      end
      
    end # InstanceMethods
      
  end # module HasRole
  
end # module Aegis
