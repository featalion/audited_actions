module AuditedActions
  class AuditedActionsController < ApplicationController
    # unloadable

    if AuditedActions::Engine.config.access_restriction_callback
      before_filter AuditedActions::Engine.config.access_restriction_callback
    end

    before_filter :set_current_user

    def index
      @entries = AuditedActionsLogEntry.all.limit(10)
    end

    # launch worker
    def create
      conf = Engine.config
      conf.iw_client.tasks.create('AuditedActionsQueueProcessingWorker',
                                  {
                                    token: conf.token,
                                    project_id: conf.project_id,
                                    mongo_conf: conf.mongo
                                  })

      flash[:notice] = "IronWorker was queued"
      redirect_to :back
    end

    # re-schedule worker
    def update
    end

    private
    def set_current_user
      @current_user = send(AuditedActions::Engine.config.current_user)
    end
  end

end
