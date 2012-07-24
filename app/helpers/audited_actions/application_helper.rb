module AuditedActions
  module ApplicationHelper
    def current_page?(opts)
      super(opts) unless request && request.get?

      controller = opts.delete(:controller).to_s
      if controller == 'audited_actions'
        url_str = url_for(opts)

        request.path.end_with?(opts)
      else
        false
      end
    end
  end
end
