module AuditedActions
  class AuditedActionsLogEntry
    include Mongoid::Document
    include Mongoid::Timestamps

    # belongs_to :actor
    field :_actor, type: Hash
    #attr_readonly :_actor

    field :controller, type: String
    field :action, type: String
    field :action_object_id, type: String
    field :fullpath, type: String

    field :_associations, type: Hash
    #attr_readonly :_associations

    field :audited_at, type: DateTime

    # belongs_to :user
    def actor
      @actor ||= _actor['__klass'].constantize.find(_actor['__id']) rescue nil
    end

    def method_missing(method, *args)
      @associated_models ||= {}
      meth_s = method.to_s
      # associated model and was found?
      return @associated_models[meth_s] if @associated_models[meth_s]
      # try to find method name in the associations
      if aattr = _associations[meth_s]
        if model?(aattr)
          @associated_models[meth_s] = find_associated_model(aattr)
        else
          aattr
        end
      else
        # is not association
        super
      end
    end

    def reload_associations
      _associations.each do |name, value|
        if model?(value)
          @associated_models[name] = find_associated_model(value)
        end
      end
    end

    private
    def model?(var)
      var.is_a?(Hash) && var['__klass'] && var['__id']
    end

    def find_associated_model(opts)
      opts['__klass'].constantize.find(opts['__id']) rescue nil
    end

  end

end

