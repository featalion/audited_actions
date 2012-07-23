AuditedActions::Engine.routes.draw do
  #mount AuditedActions::Engine, at: AuditedActions::Engine.config.mount_at + 'audited_actions'
  resources :audited_actions,
            only: [:index, :create, :update],
            path_names: {create: :queue_worker, update: :schedule_worker}

  root to: 'audited_actions#index'
end
