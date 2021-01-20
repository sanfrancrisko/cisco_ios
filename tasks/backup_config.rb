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