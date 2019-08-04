require 'rubygems'
require 'bundler/setup'

require 'dotenv/load'

$LOAD_PATH.unshift(File.expand_path("lib", __dir__))

require 'thingiverse'

Thingiverse.connection = Thingiverse::Connection.new(ENV['ACCESS_TOKEN'])
