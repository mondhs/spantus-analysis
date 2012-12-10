require 'Spnt/Exp/Data/ExpInfoResult'
require 'Spnt/Exp/Data/ExpFoundResult'
require 'Spnt/Exp/Data/ExpContainerResult'
require 'Spnt/Exp/Data/ExpRecognitionResult'
require 'rubygems'
require 'roo'

module Spnt
  module Exp
    class ExpDaoService
      @@thresholdStart = 700
      @@thresholdEnd = 700
      def initialize()
      end

      ######################
      def read(report_path)
        openoffice = Openoffice.new(report_path)
        expFileName =File.basename(report_path, ".ods")
        expContainerResult =Spnt::Exp::Data::ExpContainerResult.new(expFileName)
        expContainerResult.subtitle = createSubtytle(openoffice);
        expContainerResult.expMap = readInfo(openoffice)
        expContainerResult.sampleMap = readSample(openoffice)
        expContainerResult.foundArr = readFound(openoffice)
        expContainerResult
      end

      ######################
      # do analysis and classificate results to correct, falseNegative, falsePostive
      def classificateResult(label, sampleMap, foundArr)
        expRecognitionResult = Spnt::Exp::Data::ExpRecognitionResult.new()
        #missed = sampleArr - foundArr
        # filter that was found and transform to array
        expRecognitionResult.falseNegative = sampleMap.select{|ekey, sample|
          if(matchLabels?( label, sample.label))
            nil == foundArr.detect{|found| sample.ekey == found.ekey}
          end
        }.collect { |k, v| v }

        puts "[classificateResult] %s falseNegative:  %i" % [label, expRecognitionResult.falseNegative.length]
        #puts "falseNegative: " +  falseNegative.collect{|v| "s %i  %s" % [v.id, v.ekey]}.join(", ")

        expRecognitionResult.falsePostive = foundArr.select{|found|
          sample = sampleMap[found.ekey]
          if(sample != nil && matchLabels?( label, found.label) )
            absStartDelta = (sample.shouldStart - found.foundStart).abs
            absEndDelta = (sample.shouldEnd - found.foundEnd).abs
            sample.ekey == found.ekey && (absStartDelta > @@thresholdStart || absEndDelta > @@thresholdEnd)
          else
            false
          end
        }
        puts "[classificateResult] %s falsePostive:  %i" % [label,expRecognitionResult.falsePostive.length]
        #        puts "[classificateResult] falsePostive: " + expRecognitionResult.falsePostive.collect{|v|
        #          absStartDelta = (v.shouldStart - v.foundStart).abs
        #          absEndDelta = (v.shouldEnd - v.foundEnd).abs
        #          "%i %s D[%i; %i]" % [v.id, v.ekey, absStartDelta, absEndDelta]}.join("\r\n")

        expRecognitionResult.correct = foundArr.select{|found|
          sample = sampleMap[found.ekey]
          if(sample != nil && matchLabels?( label, found.label))
            absStartDelta = (sample.shouldStart - found.foundStart).abs
            absEndDelta = (sample.shouldEnd - found.foundEnd).abs
            sample.ekey == found.ekey && absStartDelta <= @@thresholdStart && absEndDelta <= @@thresholdEnd
          else
            false
          end
        }
        #p "correct: " + expRecognitionResult.correct.collect{|v| "%i %s" % [v.id, v.ekey]}.join(", ")
        puts "[classificateResult] %s correct:  %i" % [label,expRecognitionResult.correct.length]

        expRecognitionResult
      end

      ######################
      # do analysis and classificate results to correct, falseNegative, falsePostive
      def classificateResultByLabel(sampleMap, foundArr)
        labelArr = []
        sampleMap.each{|key,value|
          labelArr << value.label
        }
        labelArr = labelArr.uniq()
        expRecognitionResultMap = {}
        labelArr.each{|label|
          puts "[classificateResultByLabel] label: %s" % label
          expRecognitionResultMap[label]= classificateResult(label,sampleMap,foundArr);
        }
        expRecognitionResultMap
      end

      private

      ######################
      # read experiment info
      #   openoffice - spread sheet object
      def readInfo(openoffice)
        openoffice.default_sheet = openoffice.sheets[1]
        puts openoffice.default_sheet.to_s
        expMap = {}

        (2..1000).each { |i|
          filename = openoffice.cell(i, 'B').to_s()
          break if filename.empty?
          expMap[filename]=Spnt::Exp::Data::ExpInfoResult.new(filename)
          expMap[filename].processedTime=openoffice.cell(i, 'C').to_i()
          expMap[filename].audioLength=openoffice.cell(i, 'F').to_i()
        }
        expMap
      end

      ######################
      # read found information
      #   openoffice - spread sheet object
      def readFound(openoffice)
        openoffice.default_sheet = openoffice.sheets[3]
        puts openoffice.default_sheet.to_s
        foundArr = []

        (2..1000).each { |i|
          ekey = openoffice.cell(i, 'B').to_s()
          break if ekey.empty?
          foundEelement =Spnt::Exp::Data::ExpFoundResult.new(ekey)
          foundEelement.id =  openoffice.cell(i, 'A').to_i()
          foundEelement.filename = openoffice.cell(i, 'C').to_s()
          foundEelement.label = openoffice.cell(i, 'D').to_s()
          foundEelement.shouldStart = openoffice.cell(i, 'E').to_i()
          foundEelement.shouldEnd = openoffice.cell(i, 'F').to_i()
          foundEelement.foundStart = openoffice.cell(i, 'G').to_i();
          foundEelement.foundEnd = openoffice.cell(i, 'H').to_i();
          foundEelement.mfcc = openoffice.cell(i, 'I').to_f();
          foundArr  << foundEelement
        }
        foundArr
      end

      ######################
      # read information what existed
      #   openoffice - spread sheet object
      def readSample(openoffice)
        openoffice.default_sheet = openoffice.sheets[2]
        puts openoffice.default_sheet.to_s
        sampleMapByKey = {}
        (2..1000).each { |i|
          ekey = openoffice.cell(i, 'B').to_s()
          break if ekey.empty?
          sampleEelement =Spnt::Exp::Data::ExpFoundResult.new(ekey)
          sampleEelement.id =  openoffice.cell(i, 'A').to_i()
          sampleEelement.filename = openoffice.cell(i, 'C').to_s()
          sampleEelement.label = openoffice.cell(i, 'D').to_s()
          sampleEelement.shouldStart = openoffice.cell(i, 'E').to_i()
          sampleEelement.shouldEnd = openoffice.cell(i, 'F').to_i()
          sampleMapByKey[ekey] = sampleEelement
        }
        sampleMapByKey
      end

      def matchLabels?( label, foundLabel)
        #puts "[matchLabels]#{label} #{foundLabel} #{label == nil ||  label == foundLabel}"
        label == nil ||  label == foundLabel
      end

      def createSubtytle(openoffice)
        openoffice.default_sheet = openoffice.sheets[0]
        puts openoffice.default_sheet.to_s
        subtytle = openoffice.cell(1, 'A').to_s()
        subtytle
      end

    end
  end
end
