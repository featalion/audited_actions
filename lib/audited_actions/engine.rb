require 'mongoid'

module AuditedActions
  class Engine < ::Rails::Engine
    isolate_namespace AuditedActions

    initializer "audited_actions.after_config" do |app|
      # current_user
      config.current_user = if config.respond_to?(:current_user)
        (config.current_user || :current_user).to_sym
      else
        :current_user
      end

      # access_restriction_callback
      config.access_restriction_callback =
        if config.respond_to?(:access_restriction_callback)
          arc = config.access_restriction_callback

          arc ? arc.to_sym : nil
        else
          nil
        end

      # queue_name
      config.queue_name = if config.respond_to?(:queue_name)
        config.queue_name ? config.queue_name.to_s : 'audited_actions'
      else
        'audited_actions'
      end

      # known_models, only Classes are allowed values
      config.known_models =
        if config.respond_to?(:known_models)
          case config.known_models.class
          when Array
            km = config.known_models << Mongoid::Document
            km.uniq!
            km.delete_if { |m| m.class != Class }
            km
          when Class
            [config.known_models, Mongoid::Document].uniq
          else
            [Mongoid::Document]
          end
        else
          [Mongoid::Document]
        end


      config.sender = AuditedActions::IronMQSender.new(config)
      config.iw_client = ::IronWorkerNG::Client.new(token: config.token,
                                                    project_id: config.project_id)
    end

    def self.known_model?(variable)
      return false if (variable.class.ancestors & config.known_models).empty?

      true
    end

  end

end
