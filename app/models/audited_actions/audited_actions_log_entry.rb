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
        m = find_and_instantiate_associated_models(aattr)

        m ? (@associated_models[meth_s] = m) : aattr
      else
        # is not association
        super
      end
    end

    def reload_associations
      _associations.each do |name, value|
        m = find_and_instantiate_associated_models(value)
        @associated_models[name] = m if m
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

    def find_and_instantiate_associated_models(value)
      result = nil
      if model?(value)
        result = find_associated_model(value)
      elsif value.is_a?(Array)
        # find and instantiate models in Arrays (collections)
        collection = []
        value.each do |item|
          collection << find_associated_model(item) if model?(item)
        end

        result = collection unless collection.empty?
      end

      result
    end
  end

end

