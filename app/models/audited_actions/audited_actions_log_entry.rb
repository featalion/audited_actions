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
      @actor ||= find_associated_model(_actor)
    end

    def method_missing(method, *args)
      @associated_models ||= {}
      meth_s = method.to_s
      # associated model and was found?
      return @associated_models[meth_s] if @associated_models.has_key?(meth_s)
      # try to find method name in the associations
      if association?(meth_s)
        aattr = _associations[meth_s]
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

    def association?(method)
      _associations.has_key?(method.to_s)
    end

    def self.by_actor(user)
      if Engine.known_model?(user)
        where(_actor: {__klass: user.class.name, __id: user.id}.to_json)
      else
        raise "Audited Actions: user must be known model"
      end
    end

    private
    def model?(variable)
      variable.is_a?(Hash) && variable['__klass'] && variable['__id']
    end

    def find_associated_model(opts)
      opts['__klass'].constantize.find(opts['__id']) rescue nil
    end

  end

end

