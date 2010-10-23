module Decaptcha
  module Provider
    class Base
      include Error
      
      def mime_type(filename)
        filename = File.basename(filename)
        
        if filename =~  /.jp(e)g$/
          "image/jpeg"
        elsif filename =~  /.png$/
          "image/png"
        elsif filename =~  /.gif$/
          "image/gif"
        end
      end

    end
  end
end