require 'json'
require 'iron_mq'

module AuditedActions
  class IronMQSender
    def initialize(config)
      imq = IronMQ::Client.new({ token: config.token,
                                 project_id: config.project_id })
      @imqueue = imq.queue(config.queue_name)
      puts "IronMQSender was initialized, selected queue: #{config.queue_name}"
    end

    def push(data)
      @imqueue.post(prepare(data).to_json)
    end

    private
    def prepare(data)
      if data.class != Hash
        raise "AuditedActions::IronMQSender.push(): `data` must be Hash"
      end

      data[:audited_at] = Time.now

      unless Engine.known_model?(data[:_actor])
        raise "User class must be a model!"
      end

      data[:_actor] = {
        __klass: data[:_actor].class.name,
        __id: data[:_actor].id.to_s
      }

      data[:_associations] ||= {}
      data[:_associations].each do |name, assoc|
        if Engine.known_model?(assoc)
          data[:_associations][name] = {
            __klass: assoc.class.name,
            __id: assoc.id.to_s
          }
        end
      end

      data
    end

  end

end
