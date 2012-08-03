module AuditedActions
  class AuditedActionsController < ApplicationController
    # unloadable

    if AuditedActions::Engine.config.access_restriction_callback
      before_filter AuditedActions::Engine.config.access_restriction_callback
    end

    before_filter :set_current_user

    def index
      @page = params[:page].to_i
      @per_page = [params[:per_page].to_i, 1].max

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
      interval = params[:interval].to_i
      if interval < 1
        flash[:error] = "Interval must be at least one minute"
      else
        conf = Engine.config
        iw_client = conf.iw_client

        # TODO: add possibility to manage schedules,
        #       cancel all schedules with worker name for now.
        iw_client.schedules.list.each do |sch|
          if sch.code_name == 'AuditedActionsQueueProcessingWorker'
            iw_client.schedules.cancel(sch.id)
          end
        end

        iw_client.schedules.create('AuditedActionsQueueProcessingWorker',
                                   {
                                     token: conf.token,
                                     project_id: conf.project_id,
                                     queue_name: conf.queue_name,
                                     mongo_conf: conf.mongo
                                   },
                                   {
                                     start_at: Time.now + 30, # launch on schedule
                                     run_every: interval * 60, # in seconds
                                     priority: 1 # high priority in queue
                                   })
        flash[:notice] = "Worker was successfully queued"
      end

      redirect_to :back
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
