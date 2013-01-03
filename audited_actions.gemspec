$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "audited_actions/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "audited_actions"
  s.version     = AuditedActions::VERSION
  s.authors     = ["Yury Yantsevich"]
  s.email       = ["yury@iron.io"]
  s.homepage    = "http://iron.io"
  s.summary     = "AuditedActions is Rails (3.2) plugin provided engine to audit user actions."
  s.description = "AuditedActions."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2"
  s.add_dependency "mongoid"
  s.add_dependency "iron_mq"
  s.add_dependency "iron_worker_ng"

  s.add_development_dependency "sqlite3"
end
