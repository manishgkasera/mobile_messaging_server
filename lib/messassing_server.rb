require 'bundler'
Bundler.require
require 'socket'

require_relative 'setup_db'
require_relative 'niki/client_message'
require_relative 'niki/client_handler'
require_relative 'niki/server'

module Niki
end