require 'Spnt/Exp/Data/ExpInfoResult'
require 'Spnt/Exp/Data/ExpFoundResult'
require 'Spnt/Exp/Data/ExpContainerResult'
require 'Spnt/Exp/Data/ExpRecognitionResult'
require 'csv'
require 'set'

#require 'rubygems'
#require 'roo' #this is useless for this task as cannot write to file
#require 'odf/spreadsheet' #jruby -S gem install rodf


module Spnt
  module Exp
    class ExpDaoService
      @@thresholdStart = 300
      @@thresholdEnd = 300
      @@UNDEFINED_CELL = 0
      def initialize()
      end

      ######################
      def read(report_path)
        #openoffice = Roo::OpenOffice.new(report_path)
        #openoffice = Ods.new(report_path)
        expFileName =File.basename(report_path, ".ods")
        expFilePath = File.dirname(report_path) + "/" + File.basename(report_path, ".ods")
        expContainerResult =Spnt::Exp::Data::ExpContainerResult.new(expFileName)
        expContainerResult.subtitle = createSubtytle(expFilePath);
        expContainerResult.expMap = readInfo(expFilePath)
        expContainerResult.sampleMap = readSample(expFilePath)
        expContainerResult.foundArr = readFound(expFilePath)
        expContainerResult
      end

      ######################
      # do analysis and classificate results to correct, falseNegative, falsePostive
      def classificateResult(label, sampleMap, foundAllArr)
        puts "[classificateResult] started label #{label}"
        foundArr = foundAllArr.select{|found|  matchLabels?(found.label, label)}
        expRecognitionResult = Spnt::Exp::Data::ExpRecognitionResult.new()
        expRecognitionResult.falseNegative = []
        expRecognitionResult.falsePostive = []
        #missed = sampleArr - foundArr
        #1 step. filter that was found and transform to array
        substituted = sampleMap.select{|ekey, sample|
          if(matchLabels?( label, sample.label))
            nil == foundArr.detect{|found| sample.ekey == found.ekey && found.shouldStart != @@UNDEFINED_CELL} 
          end
        }.collect { |k, v| v }
        deleted =foundArr.select{|found|
          found.foundStart == nil || found.foundStart == @@UNDEFINED_CELL 
        }
        inserted =foundArr.select{|found|
          found.shouldStart == nil || found.shouldStart == @@UNDEFINED_CELL 
        }
        
        puts "[classificateResult] %s substituted:  %i" % [label, substituted.length]
        puts "[classificateResult] %s deleted:  %i" % [label, deleted.length]
        puts "[classificateResult] %s inserted:  %i" % [label, inserted.length]

        expRecognitionResult.falseNegative = (expRecognitionResult.falseNegative << substituted).flatten
        expRecognitionResult.falseNegative = (expRecognitionResult.falseNegative << deleted).flatten
        expRecognitionResult.falsePostive = (expRecognitionResult.falsePostive << inserted).flatten
        
        puts "[classificateResult] %s falseNegative:  %i" % [label, expRecognitionResult.falseNegative.length]
        puts "[classificateResult] %s falsePostive:  %i" % [label, expRecognitionResult.falsePostive.length]


        puts "[classificateResult]substituted: " +  substituted.collect{|v| " %i => %s[%s]" % [v.id, v.ekey, v.foundStart]}.join("; ")

#        foundDuplicates = {}
#        expRecognitionResult.correct = foundArr.select{|found|
#          sample = sampleMap[found.ekey]
#          if(sample != nil && matchLabels?( label, found.label))
#            if(found.foundStart == nil)
#              #puts "[classificateResult]falseNegative [#{found.ekey}] no start: #{sample.shouldStart} #{found.foundStart}"
#              expRecognitionResult.falseNegative << sample
#              false
#            else
#              absStartDelta = (sample.shouldStart - found.foundStart).abs
#              absEndDelta = (sample.shouldEnd - found.foundEnd).abs
#              matched = sample.ekey == found.ekey && absStartDelta <= @@thresholdStart && absEndDelta <= @@thresholdEnd
#              if matched == true
#                foundDuplicateElement = foundDuplicates[found.ekey]
#                if foundDuplicateElement == nil
#                  foundDuplicateElement = []
#                  foundDuplicates[found.ekey] = foundDuplicateElement
#                end
#                foundDuplicateElement << found
#                #puts "foundDuplicates[#{sample.ekey}] #{foundDuplicates[sample.ekey].length} #{matched && foundDuplicates[sample.ekey].length == 1}"
#              end
#              matched && foundDuplicates[sample.ekey].length == 1
#            end
#          else
#            false
#          end
#        }
        #expRecognitionResult.falsePostive = foundArr.select{|found| !expRecognitionResult.correct.include?(found) && !expRecognitionResult.falseNegative.include?(found)}
#        expRecognitionResult.correct = foundArr.select{|found|
#          expRecognitionResult.falsePostive.include?(found) && expRecognitionResult.falseNegative.include?(found)
#        }
        expRecognitionResult.correct = foundArr.to_set - expRecognitionResult.falsePostive.to_set - expRecognitionResult.falseNegative.to_set;
        puts "falsePostive[#{expRecognitionResult.falsePostive.length}] + falseNegative[#{expRecognitionResult.falseNegative.length}]+correct[#{expRecognitionResult.correct.length}] = foundArr[#{foundArr.length}]"
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
      def readInfo(expFileName)
        puts "[readInfo] going to open sheet"
        #openoffice.default_sheet = openoffice.sheets[1]
        #puts "[readInfo] #{openoffice.default_sheet.to_s}"
        expMap = {}
        CSV.foreach(File.path(expFileName+"_WORDSPOTINFOEXP.csv"),:headers => true) do |col|
          filename = col[1].to_s()#openoffice.cell(i, 'B').to_s()
          break if filename.empty?
          expMap[filename]=Spnt::Exp::Data::ExpInfoResult.new(filename)
          expMap[filename].processedTime=col[2].to_i()#openoffice.cell(i, 'C').to_i()
          expMap[filename].audioLength=col[5].to_i()#openoffice.cell(i, 'F').to_i()
          #puts "[readInfo] #{filename}: #{expMap[filename].processedTime}"
        end

        #        (2..10000).each { |i|
        #          start = Time.now.to_f
        #          aRow = openoffice.row(i)
        #          puts "[readInfo] seeking #{i} aRow: #{}"
        #          filename = aRow[1].to_s()#openoffice.cell(i, 'B').to_s()
        #          break if filename.empty?
        #          expMap[filename]=Spnt::Exp::Data::ExpInfoResult.new(filename)
        #          expMap[filename].processedTime=aRow[2].to_i()#openoffice.cell(i, 'C').to_i()
        #          expMap[filename].audioLength==aRow[5].to_i()#openoffice.cell(i, 'F').to_i()
        #
        #        }
        expMap
      end

      ######################
      # read found information
      #   openoffice - spread sheet object
      def readFound(expFileName)
        #openoffice.default_sheet = openoffice.sheets[3]
        puts "[readFound] started"
        #sheet = openoffice.sheets[3]
        foundArr = []

        CSV.foreach(File.path(expFileName+"_WORDSPOTFOUNDEXP.csv"),:headers => true) do |col|
          ekey = col[1].to_s()#B
          foundElement =Spnt::Exp::Data::ExpFoundResult.new(ekey)
          foundElement.id =  col[0].to_i()#A
          foundElement.filename = col[2].to_s()#C
          foundElement.label = col[3].to_s()#openoffice.cell(i, 'D').to_s()
          #puts "[readFound] #{foundElement.label}"
          foundElement.shouldStart = col[4].to_i() #openoffice.cell(i, 'E').to_i()
          foundElement.shouldEnd = col[5].to_i()#openoffice.cell(i, 'F').to_i()
          if(col[6]!=nil)
            foundElement.foundStart = col[6].to_i()#openoffice.cell(i, 'G').to_i();
          end
          if(col[7]!=nil)
            foundElement.foundEnd = col[7].to_i()#openoffice.cell(i, 'H').to_i();
          end
          if(col[8]!=nil)
            foundElement.mfcc = col[8].to_f()#openoffice.cell(i, 'I').to_f();
          end
          #if(foundElement.foundStart != @@UNDEFINED_CELL )
            foundArr  << foundElement
          #end
        end

        foundArr
      end

      ######################
      # read information what existed
      #   openoffice - spread sheet object
      def readSample(expFileName)
        #openoffice.default_sheet = openoffice.sheets[2]
        #puts openoffice.default_sheet.to_s
        file_WORDSPOTSAMPLEEXP = File.path(expFileName+"_WORDSPOTSAMPLEEXP.csv")
        puts "[readSample] started: #{file_WORDSPOTSAMPLEEXP}"
        #sheet = openoffice.sheets[2]
        sampleMapByKey = {}
        CSV.foreach(file_WORDSPOTSAMPLEEXP,:headers => true) do |col|
          ekey = col[1].to_s()#B
          break if ekey.empty?
          sampleElement =Spnt::Exp::Data::ExpFoundResult.new(ekey)
          sampleElement.id = col[0].to_i()#A
          sampleElement.filename = col[2].to_s()#C
          sampleElement.label = col[3].to_s()#D
          sampleElement.shouldStart = col[4].to_i()#E
          sampleElement.shouldEnd = col[5].to_i()#F
          sampleMapByKey[ekey] = sampleElement
        end

        #        (2..10000).each { |i|
        #          ekey = openoffice.cell(i, 'B').to_s()
        #          break if ekey.empty?
        #          sampleElement =Spnt::Exp::Data::ExpFoundResult.new(ekey)
        #          sampleElement.id =  openoffice.cell(i, 'A').to_i()
        #          sampleElement.filename = openoffice.cell(i, 'C').to_s()
        #          sampleElement.label = openoffice.cell(i, 'D').to_s()
        #          sampleElement.shouldStart = openoffice.cell(i, 'E').to_i()
        #          sampleElement.shouldEnd = openoffice.cell(i, 'F').to_i()
        #          sampleMapByKey[ekey] = sampleElement
        #          puts "[readSample] done #{i}: #{ekey}"
        #        }
        sampleMapByKey
      end

      def matchLabels?( label, foundLabel)
        #puts "[matchLabels]#{label} #{foundLabel} #{label == nil ||  label.casecmp(foundLabel) == 0}"
        label == nil ||  label.casecmp(foundLabel) == 0
      end

      def createSubtytle(expFileName)
        subtytle = ""
        CSV.foreach(File.path(expFileName+"_INFO.csv"),:headers => false) do |col|
          subtytle = col[0];
          break;
        end
        #sheet = openoffice.sheets[0]
        #puts sheet.to_s
        #subtytle = openoffice.cell(1, 'A').to_s()
        puts "[createSubtytle] #{subtytle}"
        subtytle
      end

    end
  end
end
