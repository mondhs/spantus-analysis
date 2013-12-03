require 'Spnt/Exp/ExpDaoService'
require 'Spnt/Exp/ExpDrawService'

module Spnt
  module Exp
    class ExpFacade
      def initialize
        @expDaoService = Spnt::Exp::ExpDaoService.new()
        @expDrawService = Spnt::Exp::ExpDrawService.new()
      end

      def readAndDraw(report_path)
        puts "[readAndDraw] #{report_path}"
        expContainerResult = @expDaoService.read(report_path)
        #@expDrawService.drawTotals(expContainerResult)
        expRecognitionResultMap = @expDaoService.classificateResultByLabel(expContainerResult.sampleMap,expContainerResult.foundArr)
        @expDrawService.drawRecognition(expContainerResult.expFileName, expContainerResult.subtitle ,expRecognitionResultMap)
        [expRecognitionResultMap,expContainerResult]
      end
    end
  end
end
