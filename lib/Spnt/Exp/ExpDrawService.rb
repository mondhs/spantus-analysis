require 'rubygems'
require 'roo'
require 'SVG/Graph/ErrBar'
require 'SVG/Graph/Bar'
require 'Spnt/Exp/Stat'
require 'Spnt/Exp/ExpStatService'

module Spnt
  module Exp
    class ExpDrawService
      @@width=620
      @@height=480
      def initialize()
      end

      ################################
      # Draw totals
      def drawTotals(expContainerResult)

        processedTimeArr = expContainerResult.expMap().collect { |k, v| v.processedTime }
        audioLengthTimeArr= expContainerResult.expMap().collect { |k, v| v.audioLength }

        drawProcessingTotal(expContainerResult.expFileName, expContainerResult.subtitle, processedTimeArr.sum/1000, audioLengthTimeArr.sum/1000)
        #drawProcessingAverage(expContainerResult.expFileName, processedTimeArr, audioLengthTimeArr)
      end

      def drawProcessingRatio(calculationRatioMap)
        data_processed = []
        fields = [];
        calculationRatioMap.each{|expContainerResult, ratio|
          fields << expContainerResult.subtitle
          data_processed << ratio
          puts "[drawProcessingRatio]#{expContainerResult.subtitle};#{ratio}"
        }

        graph = SVG::Graph::Bar.new(
        :height => @@height,
        :width => @@width,
        :rotate_x_labels => true,
        :show_y_title         => true,
        :y_title => 'ratio',
        :show_graph_title      => true,
        :graph_title          => "Processing Time / Signal Length",
        :stack => :side,
        :fields => fields
        )

        graph.add_data(
        :data => data_processed,
        :title => 'Data Processed Total'
        )

        File.open("./target/ratio-total.svg" , 'w') {|f|
          f << graph.burn
        }
      end

      ################################
      def drawRecognition(expFileName,subtitle, expRecognitionResultMap)

        sumaSummarum = 0
        expRecognitionResultMap.each{|key, expRecognitionResult|
          sumaSummarum += expRecognitionResult.falseNegative.length
          sumaSummarum += expRecognitionResult.falsePostive.length
          sumaSummarum += expRecognitionResult.correct.length
        }
        confidence = 0.98
        errorBars = [confidence/Math.sqrt(sumaSummarum)*100,
          confidence/Math.sqrt(sumaSummarum)*100,
          confidence/Math.sqrt(sumaSummarum)*100]

        fields = ["False Negative", "False Positive", "Correct"];
        graph = SVG::Graph::ErrBar.new(
        :height => @@height,
        :width => @@width,
        :number_format => '%.0f',
        :show_data_values=> true,
        :add_popups=>true,
        :stack => :side,
        #:rotate_x_labels => true,
        :show_y_title         => true,
        :y_title => '%',
        :show_graph_title      => true,
        :graph_title          => "Recognition Results",
        :show_graph_subtitle => true,
        :graph_subtitle => subtitle,
        :fields => fields,
        :errorBars =>errorBars
        )
        open("./target/recognition.csv", 'a') { |f|
          expRecognitionResultMap.each{|key, expRecognitionResult|
            falseNegative = expRecognitionResult.falseNegative
            falsePostive = expRecognitionResult.falsePostive
            correct = expRecognitionResult.correct

            totalNum = 100 
            #(falseNegative.length  +
            #falsePostive.length +
            #correct.length).to_f
            data_processed = [100*(falseNegative.length.to_f/totalNum),
              100*(falsePostive.length.to_f/totalNum),
              100*(correct.length.to_f/totalNum)]
            graph.add_data(
            :data => data_processed,
            :title => "#{key}"
            )
            f << "%s;%s;%s;%s\n" %[expFileName, key, data_processed.join(";"), errorBars.join(";")]
          }

        }
        File.open("./target/%s-recognition.svg" % expFileName , 'w') {|f|
          f << graph.burn
        }
      end

      def drawRecognitionByLabel(expFileName, falseNegative, falsePostive, correct)
        totalNum = (falseNegative.length  + falsePostive.length + correct.length).to_f
        data_processed = [falseNegative.length.to_f/totalNum,
          falsePostive.length.to_f/totalNum,
          correct.length.to_f/totalNum]
        confidence = 0.98
        errorBars = [confidence/Math.sqrt(totalNum),
          confidence/Math.sqrt(totalNum),
          confidence/Math.sqrt(totalNum)]

        fields = ["False Negative", "False Positive", "Correct"];
        graph = SVG::Graph::ErrBar.new(
        :height => 500,
        :width => @@width,
        :show_data_values=> true,
        :add_popups=>true,
        #:rotate_x_labels => true,
        :stack => :side,
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
      def drawProcessingTotal(expFileName, subtitle ,processedTimeArrSum, audioLengthTimeArrSum)
        data_processed = [processedTimeArrSum, audioLengthTimeArrSum]

        fields = ["Processed Time", "Audio Length"];
        graph = SVG::Graph::Bar.new(
        :height => @@height,
        :width => @@width,
        #:rotate_x_labels => true,
        :show_y_title         => true,
        :y_title => 'sec.',
        :show_graph_title      => true,
        :graph_title          => "Processing Time vs Signal Length",
        :show_graph_subtitle => true,
        :graph_subtitle => subtitle,
        :stack => :side,
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
        :height => @@height,
        :width => @@width,
        :show_data_values=> true,
        :add_popups=>true,
        #:rotate_x_labels => true,
        :stack => :side,
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
