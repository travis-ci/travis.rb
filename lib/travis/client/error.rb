require 'travis/client'

module Travis
  module Client
    class Error < StandardError
    end

    class NotFound < Error
    end

    class NotLoggedIn < Error
    end
  end
end