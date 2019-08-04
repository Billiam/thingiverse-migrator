#!/usr/bin/env ruby

$:.unshift __dir__
require 'bootstrap'

username = ARGV[0]

raise "Username is required" unless username
output_directory = Pathname.new(File.join(__dir__, 'things'))

Thingiverse::Backup.new(username, output_directory).run
