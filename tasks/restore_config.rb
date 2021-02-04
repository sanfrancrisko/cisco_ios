#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true

require_relative '../lib/puppet/util/task_helper'
task = Puppet::Util::TaskHelper.new('cisco_ios')

result = {}

unless Puppet.settings.global_defaults_initialized?
  Puppet.initialize_settings
end

VALID_CISCO_HEADERS = ['show running-config', 'Building configuration', 'Current configuration']

def config_to_restore(raw_config_output)
  header_match_count = 0
  line = 0
  start_line = 0
  end_line = 0

  raw_config_output.each do |rco|
    header_match_count += 1 if VALID_CISCO_HEADERS.select { |vch| rco.start_with? vch }.size == 1
    start_line = (line + 1) if (header_match_count == 3) && (rco.start_with? 'version')
    end_line = line if rco.start_with? 'end'
    break if start_line.positive? && end_line.positive?
    # If we haven't found the headers by line 20, let's exit as this doesn't seem to be a valid Cisco
    # backup config retrieved using 'show running-config'
    raise 'Could not detect expected headers from Cisco backup' if line >= 20 && header_match_count < 3
    line += 1
  end

  raise 'Could not determine end of config' if end_line == 0
  raw_config_output[start_line..end_line].join("")
end

begin
  # TODO: Grab 'Last configuration change' line and timestamp
  config_to_restore = config_to_restore(File.readlines(task.params['backup_location']))
  task.transport.restore_config_conf_t_mode(config_to_restore)

  result = {
    last_config_change: ''
  }
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