require 'Spnt/Exp/Data/ExpInfoResult'
require 'Spnt/Exp/Data/ExpFoundResult'
require 'Spnt/Exp/Data/ExpContainerResult'
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
        expContainerResult.expMap = readInfo(openoffice)
        expContainerResult.sampleMap = readSample(openoffice)
        expContainerResult.foundArr = readFound(openoffice)
        expContainerResult
      end

      ######################
      # do analysis and classificate results to correct, falseNegative, falsePostive
      def classificateResult(sampleMap, foundArr)

        #missed = sampleArr - foundArr
        # filter that was found and transform to array
        falseNegative = sampleMap.select{|ekey, sample|
          nil == foundArr.detect{|found| sample.ekey == found.ekey}
        }.collect { |k, v| v }

        p "falseNegative: " +  falseNegative.collect{|v| "s %i  %s" % [v.id, v.ekey]}.join(", ")

        falsePostive = foundArr.select{|found|
          sample = sampleMap[found.ekey]
          if(sample != nil)
            absStartDelta = (sample.shouldStart - found.foundStart).abs
            absEndDelta = (sample.shouldEnd - found.foundEnd).abs
            sample.ekey == found.ekey && (absStartDelta > @@thresholdStart || absEndDelta > @@thresholdEnd)
          else
            false
          end
        }
        puts "falsePostive: " + falsePostive.collect{|v|
          absStartDelta = (v.shouldStart - v.foundStart).abs
          absEndDelta = (v.shouldEnd - v.foundEnd).abs
          "%i %s D[%i; %i]" % [v.id, v.ekey, absStartDelta, absEndDelta]}.join("\r\n")

        correct = foundArr.select{|found|
          sample = sampleMap[found.ekey]
          if(sample != nil)
            absStartDelta = (sample.shouldStart - found.foundStart).abs
            absEndDelta = (sample.shouldEnd - found.foundEnd).abs
            sample.ekey == found.ekey && absStartDelta <= @@thresholdStart && absEndDelta <= @@thresholdEnd
          else
            false
          end
        }
        p "correct: " + correct.collect{|v| "%i %s" % [v.id, v.ekey]}.join(", ")

        [falseNegative, falsePostive, correct]
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
        sampleMap = {}

        (2..1000).each { |i|
          ekey = openoffice.cell(i, 'B').to_s()
          break if ekey.empty?
          sampleEelement =Spnt::Exp::Data::ExpFoundResult.new(ekey)
          sampleEelement.id =  openoffice.cell(i, 'A').to_i()
          sampleEelement.filename = openoffice.cell(i, 'C').to_s()
          sampleEelement.label = openoffice.cell(i, 'D').to_s()
          sampleEelement.shouldStart = openoffice.cell(i, 'E').to_i()
          sampleEelement.shouldEnd = openoffice.cell(i, 'F').to_i()
          sampleMap[ekey] = sampleEelement
        }
        sampleMap
      end

    end
  end
end
