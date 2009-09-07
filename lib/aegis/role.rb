module Aegis
  class Role
  
    attr_reader :name, :default_permission
          
    # permissions is a hash like: permissions[:edit_user] = lambda { |user| ... }
    def initialize(name, permissions, options)
      @name = name
      @permissions = permissions
      @default_permission = options[:default_permission] == :allow ? :allow : :deny
      freeze
    end
    
    def allow_by_default?
      @default_permission == :allow
    end
    
    def may?(permission, context, *args)
      permission = Aegis::Normalization.normalize_permission(permission)
      @permissions.may?(self, permission, context, *args)
    end
    
    def may!(permission, context, *args)
      raise PermissionError, "Access denied: #{permission}" unless may?(permission, context, *args)
    end
    
    def <=>(other)
      name.to_s <=> other.name.to_s
    end

    def to_s
      name.to_s.humanize
    end
    
    def id
      name.to_s
    end

    private
    
    def method_missing(symb, *args)
      method_name = symb.to_s
      if (match = method_name.match(/^may_(.+)_(in|for)(\?|\!)$/))
        permission, severity = match[1], match[3]
        context = args.pop if args.length > 1
        severity == "!" ? may!(permission, context, *args) : may?(permission, context, *args)
      elsif (match = method_name.match(/^may_(.+)(\?|\!)$/))
        permission, severity = match[1], match[2]
        severity == "!" ? may!(permission, nil, *args) : may?(permission, nil, *args)
      else
        super
      end
    end
        
    
  end
end
