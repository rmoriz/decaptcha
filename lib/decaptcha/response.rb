module Decaptcha
  class Response
    attr_accessor :id
    attr_accessor :location
    attr_accessor :text
    attr_accessor :status
    attr_accessor :invalid
    attr_accessor :deleted
    attr_accessor :balance
    attr_accessor :banned
    
    def self.new_from_location location
      r = Response.new
      r.location = location
      location =~ /(\d+)\Z/
      r.id = $1
      r
    end
  end
end
