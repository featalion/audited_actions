require 'mongoid'

module AuditedActions
  class Engine < ::Rails::Engine
    isolate_namespace AuditedActions

    initializer "audited_actions.after_config" do |app|
      config.current_user = (config.current_user || :current_user).to_sym

      arc = config.access_restriction_callback
      config.access_restriction_callback = arc ? arc.to_sym : nil

      config.queue_name = config.queue_name ? config.queue_name.to_s : 'audited_actions'

      config.known_models = case config.known_models.class == Array
                            when Array
                              config.known_models
                            when Class
                              [config.known_models]
                            else
                              [Mongoid::Document]
                            end


      config.sender = AuditedActions::IronMQSender.new(config)
      config.iw_client = ::IronWorkerNG::Client.new(token: config.token,
                                                    project_id: config.project_id)
    end

  end

end
