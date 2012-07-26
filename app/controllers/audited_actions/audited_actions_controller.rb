module AuditedActions
  class AuditedActionsController < ApplicationController
    # unloadable

    if AuditedActions::Engine.config.access_restriction_callback
      before_filter AuditedActions::Engine.config.access_restriction_callback
    end

    before_filter :set_current_user

    def index
      @page = params[:page].to_i
      @per_page = (params[:per_page] || 10).to_i

      all_entries = AuditedActionsLogEntry.all
      offset = ([@page, 1].max - 1) * @per_page
      @entries = all_entries.offset(offset).limit(@per_page)

      @total_entries = all_entries.count
      total_pages(@total_entries, @per_page)
    end

    # launch worker
    def create
      conf = Engine.config
      conf.iw_client.tasks.create('AuditedActionsQueueProcessingWorker',
                                  {
                                    token: conf.token,
                                    project_id: conf.project_id,
                                    queue_name: conf.queue_name,
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

    def total_pages(num, per)
      @total_pages = num / per + ((num % per == 0) ? 0 : 1)
    end
  end

end
