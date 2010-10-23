require 'forwardable'

module Decaptcha
  class Client 
    extend Forwardable
    attr_accessor :provider
    
    PROVIDERS = {
      :dbc_http   => Decaptcha::Provider::DeathByCaptcha::HTTP,
      :dbc_socket => Decaptcha::Provider::DeathByCaptcha::Socket,
    }
    
    def initialize(provider_name, provider_options = {})
      @provider = PROVIDERS[provider_name.to_sym].new provider_options
    end

    def_delegators :@provider, :connect, :upload, :upload_and_poll, :result, :invalid, :delete, :balance
  end
end