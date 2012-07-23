module AuditedActions
  module ActionControllerMethods
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def audited_actions(*args)
        opts = args.extract_options!

        cattr_accessor :audited_action_actor
        actor = opts[:actor] || AuditedActions::Engine.config.current_user
        self.audited_action_actor = actor.to_sym

        cattr_accessor :audited_action_associations
        self.audited_action_associations =
          audited_actions_parse_associations(opts[:associate])

        include AuditedActions::ActionControllerMethods::LocalInstanceMethods

        after_filter :log_audited_action, only: args
      end

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
        log_data = {
          # using `params` & `request` defined by Rails
          controller: params['controller'],
          action: params['action'],
          action_object_id: params['id'],
          fullpath: request.fullpath,
          _actor: send(audited_action_actor)
        }

        associations = {}
        audited_action_associations.each do |key, var_name|
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
