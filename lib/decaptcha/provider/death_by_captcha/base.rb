module Decaptcha
  module Provider
    module DeathByCaptcha
      class Base < Decaptcha::Provider::Base
        attr_accessor :login
        attr_accessor :password
        attr_accessor :timeout
    
        def initialize(args = {})
          @login    = args[:login]
          @password = args[:password]
          @timeout  = args[:timeout] ? args[:timeout] : '120' # seconds
        end

      end
    end
  end
end