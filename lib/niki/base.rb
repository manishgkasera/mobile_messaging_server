require 'bundler'
Bundler.require
require 'socket'
require_relative '../setup_db'
require_relative 'client_message'
require_relative 'client_handler'
require_relative 'server'