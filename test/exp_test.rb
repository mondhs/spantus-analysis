$: << File.dirname(__FILE__) + '/../lib'
require 'test/unit'
require 'Spnt/Exp/ExpDaoService'
require 'Spnt/Exp/ExpDrawService'

class ExpTest < Test::Unit::TestCase
  def setup
    @expDaoService = Spnt::Exp::ExpDaoService.new()
    @expDrawService = Spnt::Exp::ExpDrawService.new()
    @report_path = "./data/result-1106-word-qsegment.ods"
  end

  def test_exp
    expContainerResult = @expDaoService.read(@report_path)
    @expDrawService.drawTotals(expContainerResult)
    falseNegativeNum, falsePostiveNum, correctNum = @expDaoService.classificateResult(expContainerResult.sampleMap,expContainerResult.foundArr)
    @expDrawService.drawRecognition(expContainerResult.expFileName, falseNegativeNum, falsePostiveNum, correctNum)
    assert_equal(45, expContainerResult.expMap.length)
  end

  def test_extract

    foundArr = [];
    foundArr << createExpFoundResult("correct_1", 20, 110)
    foundArr << createExpFoundResult("duplicated_1",  200, 300)
    foundArr << createExpFoundResult("duplicated_1",  250, 290)

    sampleArr = []
    sampleArr<< createExpSampleResult("correct_1", 21, 110)
    sampleArr<< createExpSampleResult("duplicated_1", 200, 300)
    sampleArr<< createExpSampleResult("not_found_1", 110, 120)

    sampleMap = Hash[sampleArr.map { |p| [p.ekey, p] }]

    falseNegative, falsePostive, correct = @expDaoService.classificateResult(sampleMap,foundArr)
      
    assert_equal(1,falseNegative.length,"falseNegative")
    assert_equal(1,falsePostive.length,"falseNegative")
    assert_equal(2,correct.length,"correct")
  end

  private

  #################
  def createExpSampleResult(ekey, shouldStart, shouldEnd)
    foundEelement =Spnt::Exp::Data::ExpFoundResult.new(ekey)
    foundEelement.filename = "file%s.txt" % ekey
    foundEelement.label = "label%s" % ekey
    foundEelement.shouldStart = shouldStart * 100
    foundEelement.shouldEnd = shouldEnd * 100
    foundEelement
  end

  def createExpFoundResult(ekey,  foundStart, foundEnd)
    foundEelement =Spnt::Exp::Data::ExpFoundResult.new(ekey)
    foundEelement.filename = "file%s.txt" % ekey
    foundEelement.label = "label%s" % ekey
    foundEelement.foundStart = foundStart * 100
    foundEelement.foundEnd = foundEnd * 100
    foundEelement.shouldStart = 0
    foundEelement.shouldEnd = 0    
    foundEelement
  end

end
