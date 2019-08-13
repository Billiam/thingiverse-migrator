#!/usr/bin/env ruby

$:.unshift __dir__

require 'bootstrap'
require 'app'

Migrator.start(ARGV)
