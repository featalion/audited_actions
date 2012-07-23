$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "audited_actions/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "audited_actions"
  s.version     = AuditedActions::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of AuditedActions."
  s.description = "TODO: Description of AuditedActions."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.6"
  s.add_dependency "mongoid"
  s.add_dependency "iron_mq"
  s.add_dependency "iron_worker_ng"

  s.add_development_dependency "sqlite3"
end
