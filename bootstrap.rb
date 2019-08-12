require 'rubygems'
require 'bundler/setup'

require 'dotenv/load'

APP_ROOT = Pathname.new(File.expand_path(__dir__))

$LOAD_PATH.unshift(APP_ROOT.join('lib'))

require 'thingiverse'

Thingiverse.connection = Thingiverse::Connection.new(ENV['ACCESS_TOKEN'])
