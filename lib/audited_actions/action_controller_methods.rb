module AuditedActions
  module ActionControllerMethods
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def audited_actions(*args)
        opts = args.extract_options!
        # All argumets before options are actions,
        # parse and symbolize them
        actions = args.flatten.map { |arg| arg.to_sym }

        audited_actions_store_actions_data(actions, opts)

        include AuditedActions::ActionControllerMethods::LocalInstanceMethods

        if opts[:before_action]
          before_filter :log_audited_action, only: args
        else
          after_filter :log_audited_action, only: args
        end
      end

      def audited_actions_store_actions_data(actions, options)
        cattr_accessor :audited_actions_actor_for
        self.audited_actions_actor_for ||= {}

        cattr_accessor :audited_actions_associations_for
        self.audited_actions_associations_for ||= {}

        actor = (options[:actor] || AuditedActions::Engine.config.current_user).to_sym
        associations = audited_actions_parse_associations(options[:associate])
        # Set all data per action,
        # it allows multiple calls of `audited_actions` method on controller
        actions.each do |action|
          self.audited_actions_actor_for[action] = actor
          self.audited_actions_associations_for[action] = associations
        end
      end
      private :audited_actions_store_actions_data

      def audited_actions_parse_associations(associations)
        return {} if associations.nil?

        unless associations.is_a?(Hash)
          raise "AuditedActions' associations must be a Hash"
        end

        # drop nils and empty names
        associations.delete_if { |_, v| v.to_s == "" }
        # symbolize keys and stringify variables names
        associations.inject({}) { |mem, (k, v)| mem[k.to_sym] = v.to_s; mem }
      end
      private :audited_actions_parse_associations

    end

    module LocalInstanceMethods
      def log_audited_action
        action_sym = params['action'].to_sym

        log_data = {
          # using `params` & `request` defined by Rails
          controller: params['controller'],
          action: params['action'],
          action_object_id: params['id'],
          fullpath: request.fullpath,
          # actor for current action
          _actor: send(audited_actions_actor_for[action_sym])
        }

        associations = {}
        # each association for current action
        audited_actions_associations_for[action_sym].each do |key, var_name|
          associations[key] = self.instance_variable_get("@#{var_name}")
        end
        log_data[:_associations] = associations

        AuditedActions::Engine.config.sender.push(log_data)
      end
      private :log_audited_action

    end
  end
end

::ActionController::Base.send(:include, AuditedActions::ActionControllerMethods)
