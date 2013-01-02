require 'mongoid'
require 'iron_mq'
require 'json'

require 'audited_actions_log_entry'

if Mongoid::VERSION.start_with? '2'
  Mongoid.configure do |config|
    config.from_hash @params['mongo_conf']
  end
elsif Mongoid::VERSION.start_with? '3'
  Mongoid::Config.send(:load_configuration, @params['mongo_conf'])
else
  raise "Mongoid version #{Mongoid::VERSION} is not supported"
end

imq = IronMQ::Client.new({ token: @params['token'],
                           project_id: @params['project_id'] })
queue = imq.queue(@params['queue_name'])

qsize = queue.size
(1..qsize).each do |_|
  msg = queue.get
  AuditedActions::AuditedActionsLogEntry.create!(JSON.parse(msg.body))

  msg.delete
end

puts "processed #{qsize} messages from '#{queue.name}' queue"
