#jruby generate-natural.rb wopitch qsegment word

require File.dirname(__FILE__) + '/lib/Spnt/JdbcReport.rb'
require "fileutils"


LabelMap = {}
LabelMap["wopitch"] = "Without Pitch Static Length"
LabelMap["wpitch"] = "With Pitch Static Length"
LabelMap["dynlen"] = "With Pitch Variable Length"
LabelMap["natural"] = "Natural"

LabelMap["qsegment"] = "Qsegment"
LabelMap["scroll"] = "Scroll"
LabelMap["sphinx"] = "Sphinx"

LabelMap["word"] = "Word"
LabelMap["syl"] = "Syllable"

signal = ARGV[0]
alg = ARGV[1]
segment = ARGV[2]
  
signalLabel = LabelMap[signal]
algLabel = LabelMap[alg]
segmentLabel = LabelMap[segment]


dirName = './target/generated'
FileUtils.rm_r Dir.glob(dirName), :force => true
FileUtils.mkdir_p dirName
fileName = dirName + "/#{signal}-#{alg}-#{segment}.ods"


jdbcReport = Spnt::JdbcReport.new(fileName)
jdbcReport.generate("#{signalLabel} - #{algLabel} - #{segmentLabel}")
FileUtils.mv Dir.glob("#{dirName}/*.ods"), "/home/as/Documents/studijos/experiments/natural", :verbose => true
FileUtils.mv Dir.glob("#{dirName}/*.csv"), "/home/as/Documents/studijos/experiments/natural", :verbose => true

#system('mv', "#{dirName}/*", "/home/as/Documents/studijos/experiments/400/")
