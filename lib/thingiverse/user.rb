require 'thingiverse/resource'

module Thingiverse
  class User < Resource
    USER_PATH = '/users/%s'

    def initialize(username)
      @username = username
    end

    def things
      path = "#{full_path}/things"

      fetch_paginated(path)
    end

    def path
      USER_PATH % @username
    end
  end
end
