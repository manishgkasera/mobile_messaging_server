#!/usr/bin/env ruby

require_relative 'niki/base'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: bundle exec ./lib/messaging_server.rb [options]"
  opts.on('-p', '--port PORT', 'Port on which server should run default is 8000') { |v| options[:port] = v }
  opts.on('-v', '--verbose', 'Verbose mode') { |v| options[:verbose] = true }
end.parse!

if options.delete(:verbose)
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end

Niki::Server.start(options)
