$: << File.dirname(__FILE__) + '/../lib/*'
require 'test/unit'
require 'Spnt/Exp/ExpDaoService'
require 'Spnt/Exp/ExpDrawService'
require 'Spnt/Exp/ExpFacade'

class ExpTest < Test::Unit::TestCase
  def setup
    @expDaoService = Spnt::Exp::ExpDaoService.new()
    @expDrawService = Spnt::Exp::ExpDrawService.new()
    @expFacade  = Spnt::Exp::ExpFacade.new()
    @report_path = "./data/result-1106-word-qsegment.ods"
  end

  def test_bulk
    fileArr = [
      "/home/as/Documents/studijos/experiments/wopitch/result-1027-word-scroll.ods",
      "/home/as/Documents/studijos/experiments/wopitch/result-1027-word-qsegment.ods",
      "/home/as/Documents/studijos/experiments/wopitch/result-1104-syl-qsegment.ods",
      "/home/as/Documents/studijos/experiments/wopitch/result-1104-syl-scroll.ods",

      "/home/as/Documents/studijos/experiments/wpitch/result-1106-syl-qsegment.ods",
      "/home/as/Documents/studijos/experiments/wpitch/result-1106-syl-scroll.ods",
      "/home/as/Documents/studijos/experiments/wpitch/result-1106-word-qsegment.ods",
      "/home/as/Documents/studijos/experiments/wpitch/result-1106-word-scroll.ods",
      
#      "/home/as/Documents/studijos/experiments/dynlen/result-1113-syl-qsegment.ods",
#      "/home/as/Documents/studijos/experiments/dynlen/result-1113-syl-scroll.ods"
#      "/home/as/Documents/studijos/experiments/dynlen/result-1113-word-qsegment.ods"
#      "/home/as/Documents/studijos/experiments/dynlen/result-1113-word-scroll.ods"
    ]
    expContainerResultArr = []
    expRecognitionResultMapArr = []
    fileArr.each{|file|
      expRecognitionResultMap,expContainerResult = @expFacade.readAndDraw(file)
      expRecognitionResultMapArr << expRecognitionResultMap
      expContainerResultArr << expContainerResult
    }
    calculationRatioMap = {}
    expRecognitionResultMapArr.each_index(){|i|
      expContainerResult = expContainerResultArr[i]
      expRecognitionResultMap = expRecognitionResultMapArr[i]
      processedTimeArr = expContainerResult.expMap().collect { |k, v| v.processedTime }
      audioLengthTimeArr= expContainerResult.expMap().collect { |k, v| v.audioLength }
      ratio = processedTimeArr.sum.to_f/audioLengthTimeArr.sum.to_f
      calculationRatioMap[expContainerResult] = ratio
      @expDrawService.drawProcessingRatio(calculationRatioMap);
    }
    
  end


  private

  #################
  def createExpSampleResult(ekey, shouldStart, shouldEnd, label)
    foundEelement =Spnt::Exp::Data::ExpFoundResult.new(ekey)
    foundEelement.filename = "file%s.txt" % ekey
    foundEelement.label = label
    foundEelement.shouldStart = shouldStart * 100
    foundEelement.shouldEnd = shouldEnd * 100
    foundEelement
  end

  def createExpFoundResult(ekey,  foundStart, foundEnd,  label)
    foundEelement =Spnt::Exp::Data::ExpFoundResult.new(ekey)
    foundEelement.filename = "file%s.txt" % ekey
    foundEelement.label = label
    foundEelement.foundStart = foundStart * 100
    foundEelement.foundEnd = foundEnd * 100
    foundEelement.shouldStart = 0
    foundEelement.shouldEnd = 0
    foundEelement
  end

end
