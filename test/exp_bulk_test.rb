$: << File.dirname(__FILE__) + '/../lib/'
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
    open("./target/recognition.csv", 'w') { |f|
      f << "Exp;Segment;False Negative;False Positive;Correct\n"
    }
    fileArr = [
#     "/home/as/Documents/studijos/experiments/400/wopitch-qsegment-word.ods",
#      "/home/as/Documents/studijos/experiments/400/wopitch-scroll-word.ods",
#     "/home/as/Documents/studijos/experiments/400/wopitch-sphinx-word.ods",
#
#
#      "/home/as/Documents/studijos/experiments/400/dynlen-qsegment-word.ods",
#      "/home/as/Documents/studijos/experiments/400/dynlen-scroll-word.ods",
#      "/home/as/Documents/studijos/experiments/400/dynlen-sphinx-word.ods",
#
# 
#      "/home/as/Documents/studijos/experiments/400/wpitch-qsegment-word.ods",
#      "/home/as/Documents/studijos/experiments/400/wpitch-scroll-word.ods",
#      "/home/as/Documents/studijos/experiments/400/dynlen-sphinx-word.ods",  

#      "/home/as/Documents/studijos/experiments/natural/natural-qsegment-word.ods",
#      "/home/as/Documents/studijos/experiments/natural/natural-scroll-word.ods",
      "/home/as/Documents/studijos/experiments/natural/natural-sphinx-word.ods",

      
      #      "/home/as/Documents/studijos/experiments/400/wpitch-scroll-syl.ods",

      #      "/home/as/Documents/studijos/experiments/400/wpitch-qsegment-syl.ods",

      #      "/home/as/Documents/studijos/experiments/400/wopitch-qsegment-syl.ods",
      #      "/home/as/Documents/studijos/experiments/400/wopitch-scroll-syl.ods",

      #      "/home/as/Documents/studijos/experiments/400/dynlen-scroll-syl.ods",
      #      "/home/as/Documents/studijos/experiments/400/dynlen-qsegment-syl.ods",      
#      "/home/as/Documents/studijos/experiments/natural/natural-qsegment-syl.ods",
#      "/home/as/Documents/studijos/experiments/natural/natural-scroll-syl.ods",
      
    ]
    expContainerResultArr = []
    expRecognitionResultMapArr = []
    fileArr.each{|file|
      puts "#{file}"
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
    }
    calculationRatioMap.sort_by {|key, value| value}
    @expDrawService.drawProcessingRatio(calculationRatioMap);
    
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
