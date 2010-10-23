#require 'uri'
require 'digest/sha1'
require 'json'
require 'rest_client'
    
module Decaptcha
  module Provider
    module DeathByCaptcha
      class HTTP < Decaptcha::Provider::DeathByCaptcha::Base
        API_SERVER_URL     = 'http://www.deathbycaptcha.com/api/captcha'
        API_VERSION        = 'DBC/Ruby v3.0'
        SOFTWARE_VENDOR_ID = 0
        DEFAULT_TIMEOUT    = 60
        POLLS_PERIOD       = 15
          
        def upload(args = {})
          filename = args[:filename]

          params = {
            :captchafile => File.new(filename, 'rb'),
            :username    => @login, 
            :password    => Digest::SHA1.hexdigest(@password),
            :is_hashed   => 1,
            :swid        => SOFTWARE_VENDOR_ID,
            :version     => API_VERSION
          }
          
          RestClient.post API_SERVER_URL, params, :accept => :json do |response, request, result|
            if response.code == 303
              return Decaptcha::Response.new_from_location response.headers[:location]
            else
              raise UploadError
            end
          end
        end
        
        def upload_and_poll(args = {})
          user_timeout = args[:timeout] || DEFAULT_TIMEOUT
          response = upload(args)
          kill_time = Time.now + user_timeout
          
          while (Time.now < kill_time) do
            if result = result(response)
              break
            else
              sleep POLLS_PERIOD
            end
          end
          
          # remove...
          
          result
        end
        
        def result(response_obj)
          RestClient.get response_obj.location, :accept => :json do |response, request, result|
            if response.code == 200
              data = JSON.parse response
              response_obj.text    = data['text']
              response_obj.invalid = !data['is_correct']
              return response_obj
            else
              raise ResultError
            end
          end
        end
        
        def delete(response_obj)
          params = {
            :username    => @login, 
            :password    => Digest::SHA1.hexdigest(@password),
            :is_hashed   => 1,
            :swid        => SOFTWARE_VENDOR_ID,
            :version     => API_VERSION
          }
          
          delete_url = "#{response_obj.location}/remove"
          
          RestClient.post delete_url, params, :accept => :json do |response, request, result|
            if response.code == 200
              response_obj.deleted = true
            else
              raise DeletionError
            end
          end
          
          response_obj
        end
        
        def invalid(response_obj)
          params = {
            :username    => @login, 
            :password    => Digest::SHA1.hexdigest(@password),
            :is_hashed   => 1,
            :swid        => SOFTWARE_VENDOR_ID,
            :version     => API_VERSION
          }
          
          invalidation_url = "#{response_obj.location}/report"
          
          RestClient.post invalidation_url, params, :accept => :json do |response, request, result|
            if response.code == 200
              response_obj.invalid = true
            else
              raise InvalidationError, response
            end
          end
          
          response_obj
        end
      end
    end
  end
end