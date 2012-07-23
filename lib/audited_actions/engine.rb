require 'mongoid'

module AuditedActions
  class Engine < ::Rails::Engine
    isolate_namespace AuditedActions

    initializer "after config" do |app|
      config.current_user = (config.current_user || :current_user).to_sym

      arc = config.access_restriction_callback
      config.access_restriction_callback = arc ? arc.to_sym : nil

      config.queue_name = config.queue_name ? config.queue_name.to_s : 'audited_actions'

      config.sender = AuditedActions::IronMQSender.new(config)
      config.iw_client = ::IronWorkerNG::Client.new(token: config.token,
                                                    project_id: config.project_id)
    end

  end

end
