AuditedActions::Engine.routes.draw do
  resources :audited_actions, only: [:index, :create, :update]

  root to: 'audited_actions#index'
end
