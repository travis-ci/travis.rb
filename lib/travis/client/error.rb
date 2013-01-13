require 'travis/client'

module Travis
  module Client
    class Error < StandardError
    end

    class NotFound < Error
    end
  end
end