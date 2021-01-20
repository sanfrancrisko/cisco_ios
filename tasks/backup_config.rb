#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true

require_relative '../lib/puppet/util/task_helper'
task = Puppet::Util::TaskHelper.new('cisco_ios')

result = {}

unless Puppet.settings.global_defaults_initialized?
  Puppet.initialize_settings
end

begin
  rtn = task.transport.run_command_enable_mode('show running-config')
  result[:status]  = 'success'
  File.open(task.params['backup_location'], 'w') do |f|
    f.puts rtn
  end
  result[:results] = "show running-config successfully output to #{task.params['backup_location']}"
rescue StandardError => e
  result[:_error] = {
    msg: e.message,
    kind: 'puppetlabs/cisco_ios',
    details: {
      class: e.class.to_s,
      backtrace: e.backtrace,
    },
  }
end

puts result.to_json


























# # DEV (bundle exec ruby)
# require "/Users/ciaran.mccrisken/sanfrancrisko/cisco_ios/spec/fixtures/modules/ruby_task_helper/files/task_helper.rb"
# # PRODUCTION
# # require_relative "../../ruby_task_helper/files/task_helper.rb"
# require 'puppet'
#
# require 'pry'
# class BackupConfig < TaskHelper
#   def task(name: nil, **kwargs)
#
#     require 'pry'; binding.pry
#     {greeting: "Hi, my name is #{name}"}
#   end
# end
#
# if __FILE__ == $0
#   BackupConfig.run
# end

# begin
#   require_relative '../../puppetlabs-ruby_task_helper/files/task_helper.rb'
# rescue LoadError
#   # include location for unit tests
#   require 'spec/fixtures/modules/puppetlabs-ruby_task_helper/files/task_helper.rb'
# end

# unless Puppet.settings.global_defaults_initialized?
#   Puppet.initialize_settings
# end
#
# begin
#   results = task.transport.run_command_enable_mode('show running-config')
# rescue StandardError => e
#   puts {}
# end
#
# puts results

# begin
#   results = task.transport.run_command_enable_mode('show running-config')
#   if task.params['raw']
#     puts results
#   else
#     result = {}
#     result[:success] = 'success'
#     result[:results] = results.to_s
#     puts result.to_json
#   end
#   exit 0
# rescue StandardError => e
#   result = {}
#   result[:_error] = {
#     msg: e.message,
#     kind: 'puppetlabs/cisco_ios',
#     details: {
#       class: e.class.to_s,
#       backtrace: e.backtrace,
#     },
#   }
#   puts result.to_json
#   exit 1
# end