require 'digest/sha1'
require 'json'
require 'socket'
require 'base64'

module Decaptcha
  module Provider
    module DeathByCaptcha
      class Socket < Decaptcha::Provider::DeathByCaptcha::Base
        API_SERVER_HOST       = 'deathbycaptcha.com'
        API_SERVER_FIRST_PORT = 8123
        API_SERVER_LAST_PORT  = 8130
        API_VERSION           = 'DBC/Ruby v3.0'
        SOFTWARE_VENDOR_ID    = 0
        
        DEFAULT_TIMEOUT = 60
        POLLS_COUNT     = 4
        POLLS_PERIOD    = 15
        POLLS_INTERVAL  = 5

        def upload(args = {})
          filename = args[:filename]
          
          options = { :cmd => 'upload',
                      :captcha => Base64::encode64(File.read(filename)) }
          
          data = make_request(options)
          
          if data.nil? || data.empty?
            raise UploadError
          end

          build_response(data)
        end

        def upload_and_poll(args = {})
          user_timeout = args[:timeout] || DEFAULT_TIMEOUT
          response = upload(args)
          kill_time = Time.now + user_timeout

          response = ''
          while (Time.now < kill_time) do
            response = result(response)
            
            if response.text
              break
            elsif response.invalid
              raise InvalidationError, response
            else
              sleep POLLS_PERIOD
            end
          end
          
          # remove...

          response
        end

        def result(response_obj)
          options = { :cmd => 'get_text', :captcha => response_obj.id }
          data = make_request(options)

          if data.nil? || data.empty?
            raise ResultError
          end

          build_response(data)
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
        
        def make_request(options)
          host = TCPSocket.getaddress API_SERVER_HOST
          port = API_SERVER_FIRST_PORT + rand(API_SERVER_LAST_PORT - API_SERVER_FIRST_PORT + 1)
          
          connection = TCPSocket.new(host, port)
          connection.write compile_params(options).to_json
          
          buffer = ""
          
          while data = connection.read(1000)
            buffer = buffer + data
          end
          
          connection.close
          
          JSON.parse buffer rescue nil
        end
        
        def build_response(data)
          response = Decaptcha::Response.new
          response.id      = data['captcha']
          response.text    = data['text']
          response.invalid = !data['is_correct']
          response.banned  = data['banned']
          response.balance = data['balance']
          response
        end
        
        def compile_params(additional_params)
          params = {
             :username    => @login, 
             :password    => Digest::SHA1.hexdigest(@password),
             :is_hashed   => 1,
             :swid        => SOFTWARE_VENDOR_ID,
             :version     => API_VERSION
           }

          params.merge additional_params
        end
      end
    end
  end
end