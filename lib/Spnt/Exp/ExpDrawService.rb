require 'rubygems'
require 'roo'
require 'SVG/Graph/ErrBar'
require 'SVG/Graph/Bar'
require 'Spnt/Exp/Stat'

module Spnt
  module Exp
    class ExpDrawService
      def initialize()
      end

      ################################
      # Draw totals
      def drawTotals(expContainerResult)

        processedTimeArr = expContainerResult.expMap().collect { |k, v| v.processedTime }
        audioLengthTimeArr= expContainerResult.expMap().collect { |k, v| v.audioLength }

        drawProcessingTotal(expContainerResult.expFileName, processedTimeArr.sum, audioLengthTimeArr.sum)
        drawProcessingAverage(expContainerResult.expFileName, processedTimeArr, audioLengthTimeArr)
      end

      ################################
      def drawRecognition(expFileName, falseNegative, falsePostive, correct)
        data_processed = [falseNegativeNum, falsePostiveNum, correctNum]
        errorBars = [1, 1, 1]

        fields = %w(falseNegativeNum, falsePostiveNum, correctNum);
        graph = SVG::Graph::ErrBar.new(
        :height => 500,
        :width => 500,
        :show_data_values=> true,
        :add_popups=>true,
        :fields => fields,
        :errorBars =>errorBars
        )

        graph.add_data(
        :data => data_processed,
        :title => 'Data Processed'
        )

        File.open("./target/%s-recognition.svg" % expFileName , 'w') {|f|
          f << graph.burn
        }
      end

      private

      ################################
      def drawProcessingTotal(expFileName, processedTimeArrSum, audioLengthTimeArrSum)
        data_processed = [processedTimeArrSum, audioLengthTimeArrSum]

        fields = %w(totalProcessedTime totalAudioLength);
        graph = SVG::Graph::Bar.new(
        :height => 500,
        :width => 500,
        :fields => fields
        )

        graph.add_data(
        :data => data_processed,
        :title => 'Data Processed Total'
        )

        File.open("./target/%s-total.svg" % expFileName, 'w') {|f|
          f << graph.burn
        }
      end

      ################################
      def drawProcessingAverage(expFileName, processedTimeArr, audioLengthTimeArr)

        data_processed = [processedTimeArr.mean, audioLengthTimeArr.mean]
        errorBars = [processedTimeArr.confidence, audioLengthTimeArr.confidence]

        fields = %w(totalProcessedTime totalAudioLength);
        graph = SVG::Graph::ErrBar.new(
        :height => 500,
        :width => 500,
        :show_data_values=> true,
        :add_popups=>true,
        :fields => fields,
        :errorBars =>errorBars
        )

        graph.add_data(
        :data => data_processed,
        :title => 'Data Processed'
        )

        File.open("./target/%s-avg.svg" % expFileName , 'w') {|f|
          f << graph.burn
        }
      end

    end
  end
end
