require 'uri'
require 'digest/sha1'
require 'net/http'
require 'net/http/post/multipart'
    
module Decaptcha
  module Provider
    class DeathByCaptcha
      class HTTP < Decaptcha::Provider::DeathByCaptcha::Base
        API_SERVER_URL     = 'http://www.deathbycaptcha.com/api/captcha'
        API_VERSION        = 'DBC/Ruby v3.0'
        SOFTWARE_VENDOR_ID = 0
        DEFAULT_TIMEOUT    = 60
        POLLS_PERIOD       = 15
          
        def upload(args = {})
          filename = args[:filename]
          url = URI.parse(API_SERVER_URL)

          request = Net::HTTP::Post::Multipart.new url.path, 
            'captchafile' => UploadIO.new(filename, mime_type(filename), File.basename(filename)),
            'username'    => @login, 
            'password'    => Digest::SHA1.hexdigest(@password),
            'is_hashed'   => 1,
            'swid'        => SOFTWARE_VENDOR_ID,
            'version'     => API_VERSION
          
          http = Net::HTTP.new(url.host, url.port)
          response = http.start {|con|
             con.request(request)
          }

          case response
             when Net::HTTPSeeOther
                response.header['location'] =~ /(\d+)\z/
                cid = $1
             else
               response.error! # raises Exception
          end
          
          cid
        end
        
        
        def upload_and_poll(args = {})
          user_timeout = args[:timeout] || DEFAULT_TIMEOUT
          cid = upload(args)
          kill_time = Time.now + user_timeout
          
          while (Time.now < kill_time) do
            if result = scan(cid)
              break
            else
              puts "waiting"
              sleep POLLS_PERIOD
            end
          end
        
        end
        
        def scan(cid)
           request = Net::HTTP::Post.new url.path, 
              'username'    => @login, 
              'password'    => Digest::SHA1.hexdigest(@password),
              'is_hashed'   => 1,
              'swid'        => SOFTWARE_VENDOR_ID,
              'version'     => API_VERSION
        end
        
        def remove(cid)
        end
      end
    end
  end
end