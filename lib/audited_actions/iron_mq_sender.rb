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

      data[:_actor] = prepare_model_hash(data[:_actor])

      data[:_associations] ||= {}
      data[:_associations].each do |name, assoc|
        if Engine.known_model?(assoc)
          data[:_associations][name] = prepare_model_hash(assoc)
        elsif assoc.is_a?(Array)
          # check for models in associated Array (collections workaround)
          # accepts only models if has at least one model in
          collection = []
          assoc.each do |item|
            collection << prepare_model_hash(item) if Engine.known_model?(item)
          end

          data[:_associations][name] = collection unless collection.empty?
        end
      end

      data
    end

    def prepare_model_hash(model)
      {__klass: model.class.name, __id: model.id.to_s}
    end

  end

end
