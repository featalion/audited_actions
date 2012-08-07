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
      _actor['__klass'].constantize.find(_actor['__id']) rescue nil
    end

    def method_missing(meth, *args)
      # try to find method name in the associations
      if aattr = _associations[meth.to_s]
        if aattr.is_a?(Hash) && aattr['__klass'] && aattr['__id']
          aattr['__klass'].constantize.find(aattr['__id']) rescue nil
        else
          aattr
        end
      else
        super
      end
    end
  end

end

