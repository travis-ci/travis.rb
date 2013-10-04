require 'travis/client'

module Travis
  module Client
    class Error < StandardError
    end

    class NotFound < Error
    end

    class NotLoggedIn < NotFound
    end
  end
end