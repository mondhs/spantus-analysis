module Spnt
  module Exp
    module Data
      class ExpInfoResult
        attr_accessor :filename, :processedTime, :audioLength
        def initialize(filename)
          @filename = filename
        end
      end
    end
  end
end
