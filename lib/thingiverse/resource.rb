module Thingiverse
  def self.connection=(connection)
    @connection = connection
  end

  def self.connection
    @connection
  end

  class Resource
    extend Forwardable

    def connection
      Thingiverse.connection
    end

    def full_path
      "#{Thingiverse::HOST}/#{path}"
    end

    def_delegators :connection, :fetch, :fetch_paginated
  end
end
