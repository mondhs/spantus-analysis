#jruby generate.rb wopitch qsegment word

require File.dirname(__FILE__) + '/lib/Spnt/JdbcReport.rb'

LabelMap = {}
LabelMap["wopitch"] = "Without Pitch Static Length"
LabelMap["wpitch"] = "With Pitch Static Length"
LabelMap["dynlen"] = "With Pitch Variable Length"

LabelMap["qsegment"] = "Qsegment"
LabelMap["scroll"] = "Scroll"

LabelMap["word"] = "Word"
LabelMap["syl"] = "Syllable"

signal = ARGV[0]
alg = ARGV[1]
segment = ARGV[2]
  
signalLabel = LabelMap[signal]
algLabel = LabelMap[alg]
segmentLabel = LabelMap[segment]

fileName = "./data/test.ods"

jdbcReport = Spnt::JdbcReport.new(fileName)
jdbcReport.generate("#{signalLabel} - #{algLabel} - #{segmentLabel}")
system('mv', fileName, "/home/as/Documents/studijos/experiments/400/#{signal}-#{alg}-#{segment}.ods")