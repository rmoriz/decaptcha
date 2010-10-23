module Decaptcha
  module Provider
    module Error
      class UploadError       < RuntimeError; end
      class ResultError       < RuntimeError; end
      class DeletionError     < RuntimeError; end
      class InvalidationError < RuntimeError; end
    end
  end
end