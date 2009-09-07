module Aegis
  class PermissionEvaluator

    def initialize(role, permission, context)
      @role = role
      @context = context
      @permission = permission
    end

    def evaluate(permissions, rule_args)
      @result = @role.allow_by_default?
      permissions.each do |permission|
        instance_exec(*rule_args, &permission)
      end
      @result
    end

    def allow(*role_name_or_names, &block)
      rule_encountered(role_name_or_names, true, &block)
    end

    def deny(*role_name_or_names, &block)
      rule_encountered(role_name_or_names, false, &block)
    end
    
    def context(*class_names)
      raise Aegis::PermissionError, "permission :#{@permission} does not make sense for #{@context.class}" \
        unless class_names.collect(&:to_s).include?(@context.class.name)
    end

    def rule_encountered(role_name_or_names, is_allow, &block)
      role_names = Array(role_name_or_names)
      if role_names.include?(@role.name) || role_names.include?(Aegis::Constants::EVERYONE_ROLE_NAME)
        @result = (block ? block.call : true) 
        @result = !@result unless is_allow
      end
    end

  end
end

