require 'test/unit'
require File.dirname(__FILE__) + '/../lib/Spnt/JdbcReport.rb'

class ExpTest < Test::Unit::TestCase
  def setup
  end

  def _test_stuff
    #t = %w(ID FILENAME PROCCESSINGLENGTH EXPERIMENTSTARTED EXPERIMENTENDED AUDIOLENGTH)
    tableArr = %w{WORDSPOTINFOEXP WORDSPOTSAMPLEEXP WORDSPOTFOUNDEXP}
    columnMap = {}
    columnMap["WORDSPOTINFOEXP"] = "ID,FILENAME,PROCCESSINGLENGTH,EXPERIMENTSTARTED,EXPERIMENTENDED,AUDIOLENGTH".split(/,/)
    columnMap["WORDSPOTSAMPLEEXP"] = "ID,EKEY,FILENAME,MARKERLABEL,MARKERSTART,MARKEREND".split(/,/)
    columnMap["WORDSPOTFOUNDEXP"] = "ID,EKEY,FILENAME,MARKERLABEL,MARKERSTART,MARKEREND,FOUNDSTART,FOUNDEND,MFCCVAUE".split(/,/)
    orderByMap={}
    orderByMap["WORDSPOTINFOEXP"] = "FILENAME"
    orderByMap["WORDSPOTSAMPLEEXP"] = "FILENAME, MARKERSTART"
    orderByMap["WORDSPOTFOUNDEXP"] = "FILENAME, FOUNDSTART"
    tableArr.each{ |tableName|
      columnArr = columnMap[tableName]
      p tableName
      p columnMap[tableName]
      selectquery = "select #{columnArr.join(', ')} from #{tableName}  ORDER BY #{orderByMap[tableName]} "
      p selectquery
    }

  end

  def test_exp
    jdbcReport = Spnt::JdbcReport.new("./data/test.ods")
    jdbcReport.generate('With-pitch')
    assert_equal(1, 1)
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


