namespace :audited_actions do
  require 'iron_worker_ng'

  desc "Install IronWorker to process audited actions from IronMQ"
  task :install_worker => :environment do |_, args|
    current_dir = File.dirname(__FILE__)

    code = IronWorkerNG::Code::Ruby.new

    code.merge_gem 'mongoid'
    code.merge_gem 'iron_mq'
    code.merge_gem 'json'

    code.merge_file "#{current_dir}/../../app/models/audited_actions/audited_actions_log_entry.rb"

    code.merge_exec "#{current_dir}/files/audited_actions_queue_processing_worker.rb"

    code.name = 'AuditedActionsQueueProcessingWorker'

    client = IronWorkerNG::Client.new(token: AuditedActions::Engine.config.token,
                                      project_id: AuditedActions::Engine.config.project_id)
    client.codes.create(code)
  end

end
