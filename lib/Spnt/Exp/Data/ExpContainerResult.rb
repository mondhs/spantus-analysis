module Spnt
  module Exp
    module Data
      class ExpContainerResult
        attr_accessor :expFileName, :subtitle, :expMap, :foundArr, :sampleMap
        def initialize(expFileName)
          @expFileName = expFileName
          @expMap = {}
          @foundArr = {}
          @sampleMap={}
        end
      end
    end
  end
end
