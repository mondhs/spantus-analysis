module Spnt
  module Exp
    module Data
      class ExpFoundResult
        attr_accessor :id, :filename, :ekey, :label,
        :shouldStart, :shouldEnd,:foundStart, :foundEnd, :mfcc
        def initialize(ekey)
          @ekey = ekey
        end

        def eql? other #OVERLOADED eql? !!!
          other.kind_of?(self.class) && @ekey == other.ekey
        end

        def hash #OVERLOADED hash !!!
          @ekey.hash #use var1 hash value,
          #as hash for MyClass
        end
      end
    end
  end
end
