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

 

  def test_exp
   expRecognitionResultMap,expContainerResult = @expFacade.readAndDraw(@report_path)
    assert_equal(45, expContainerResult.expMap.length)
  end

  def test_process
    foundArr = [];
    foundArr << createExpFoundResult("correct_1", 20, 110, "label1")
    foundArr << createExpFoundResult("duplicated_1",  200, 300, "label1")
    foundArr << createExpFoundResult("duplicated_1",  250, 290, "label1")
    foundArr << createExpFoundResult("correct_2", 120, 210, "label2")
    foundArr << createExpFoundResult("duplicated_2",  300, 400, "label2")
    foundArr << createExpFoundResult("duplicated_2",  350, 390, "label2")
    foundArr << createExpFoundResult("correct_3", 1120, 1210, "label2")
    foundArr << createExpFoundResult("duplicated_3",  1300, 1400, "label2")
    foundArr << createExpFoundResult("duplicated_3",  1350, 1390, "label2")

    sampleArr = []
    sampleArr<< createExpSampleResult("correct_1", 21, 110, "label1")
    sampleArr<< createExpSampleResult("duplicated_1", 200, 300, "label1")
    sampleArr<< createExpSampleResult("not_found_1", 110, 120, "label1")
    sampleArr<< createExpSampleResult("correct_2", 121, 210, "label2")
    sampleArr<< createExpSampleResult("duplicated_2", 300, 400, "label2")
    sampleArr<< createExpSampleResult("not_found_2", 210, 220, "label2")
    sampleArr<< createExpSampleResult("correct_3", 1121, 1210, "label2")
    sampleArr<< createExpSampleResult("duplicated_3", 1300, 1400, "label2")
    sampleArr<< createExpSampleResult("not_found_3", 1210, 1220, "label2")

    sampleMap = Hash[sampleArr.map { |p| [p.ekey, p] }]

    expRecognitionResultMap = @expDaoService.classificateResultByLabel(sampleMap,foundArr)
    assert_equal(2,expRecognitionResultMap.length,"labels")
    assert_equal(1,expRecognitionResultMap["label1"].falseNegative.length,"falseNegative")
    assert_equal(1,expRecognitionResultMap["label1"].falsePostive.length,"falseNegative")
    assert_equal(2,expRecognitionResultMap["label1"].correct.length,"correct")
    assert_equal(2,expRecognitionResultMap["label2"].falseNegative.length,"falseNegative")
    assert_equal(2,expRecognitionResultMap["label2"].falsePostive.length,"falseNegative")
    assert_equal(4,expRecognitionResultMap["label2"].correct.length,"correct")

  end

  def test_extract
    foundArr = [];
    foundArr << createExpFoundResult("correct_1", 20, 110, "label")
    foundArr << createExpFoundResult("duplicated_1",  200, 300, "label")
    foundArr << createExpFoundResult("duplicated_1",  250, 290, "label")

    sampleArr = []
    sampleArr<< createExpSampleResult("correct_1", 21, 110, "label")
    sampleArr<< createExpSampleResult("duplicated_1", 200, 300, "label")
    sampleArr<< createExpSampleResult("not_found_1", 110, 120, "label")

    sampleMap = Hash[sampleArr.map { |p| [p.ekey, p] }]

    expRecognitionResult = @expDaoService.classificateResult(nil, sampleMap,foundArr)

    assert_equal(1,expRecognitionResult.falseNegative.length,"falseNegative")
    assert_equal(1,expRecognitionResult.falsePostive.length,"falseNegative")
    assert_equal(2,expRecognitionResult.correct.length,"correct")
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
