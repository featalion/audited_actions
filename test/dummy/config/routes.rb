Rails.application.routes.draw do

  mount AuditedActions::Engine => "/audited_actions"
end
