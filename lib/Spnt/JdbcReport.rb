require 'java'
require "~/.m2/repository/org/hsqldb/hsqldb/2.2.9/hsqldb-2.2.9.jar"
require 'rubygems'
#require 'roo' #this is useless for this task as cannot write to file
require 'odf/spreadsheet' #jruby -S gem install rodf
require 'csv'

module Spnt
  class JdbcReport
    @@jdbc_url = "jdbc:hsqldb:hsql://localhost/spnt-exp"
    @connection
    @report_path
    @@report_path_csv = ""
    def initialize(aReportPath)
      @@report_path_csv = File.dirname(aReportPath) + "/" + File.basename(aReportPath, ".ods")
      @report_path = aReportPath#"./data/test.ods"
      puts "report_path_csv2: #{@@report_path_csv}"
    end
    
    def is_numeric(object)
      true if Float(object) rescue false
    end



    def generate(exp_name)
      tableArr = %w{WORDSPOTINFOEXP WORDSPOTSAMPLEEXP WORDSPOTFOUNDEXP}
      columnMap = {}
      columnMap["WORDSPOTINFOEXP"] = "ID,FILENAME,PROCCESSINGLENGTH,EXPERIMENTSTARTED,EXPERIMENTENDED,AUDIOLENGTH,OPERATIONCOUNT".split(/,/)
      columnMap["WORDSPOTSAMPLEEXP"] = "ID,EKEY,FILENAME,MARKERLABEL,MARKERSTART,MARKEREND".split(/,/)
      columnMap["WORDSPOTFOUNDEXP"] = "ID,EKEY,FILENAME,MARKERLABEL,MARKERSTART,MARKEREND,FOUNDSTART,FOUNDEND,MFCCVALUE".split(/,/)
      orderByMap={}
      orderByMap["WORDSPOTINFOEXP"] = "FILENAME"
      orderByMap["WORDSPOTSAMPLEEXP"] = "FILENAME, MARKERSTART"
      orderByMap["WORDSPOTFOUNDEXP"] = "FILENAME, FOUNDSTART"
      
        
      ODF::Spreadsheet.file(@report_path) do
        puts "report_path_csv3: #{@@report_path_csv}"
        CSV.open(@@report_path_csv+"_INFO.csv", "w") do |csv|
          @connection = java.sql.DriverManager.getConnection(@@jdbc_url, "sa", "")
          selectquery = "select distinct(markerlabel) from WORDSPOTSAMPLEEXP"
          stmtSelect = @connection.create_statement
          rsS = stmtSelect.execute_query(selectquery)
          table 'Info' do
            row {
              cell exp_name
              csv << [exp_name]
            }
            row {
              p rsS
              while (rsS.next) do
                cell rsS.getObject(1)
                csv << [rsS.getObject(1)]
              end
              stmtSelect.close
            }
          end
        end
      
      tableArr.each{ |tableName|
          CSV.open(@@report_path_csv+"_"+tableName+".csv", "w") do |csv|
              columnArr = columnMap[tableName]
              selectquery = "select #{columnArr.join(', ')} from #{tableName}  ORDER BY #{orderByMap[tableName]} "
              stmtSelect = @connection.create_statement
              rsS = stmtSelect.execute_query(selectquery)
              table tableName do
                row {
                  csv << columnArr
                  columnArr.each{ |column|
                    cell column
                    
                  }
                }
                while (rsS.next) do
                  rowValues = []
                  row {
                    columnArr.each{ |column|
                      obj = rsS.getObject(column)
                      if obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil
                        rowValues << obj
                        cell obj
                      else
                        rowValues << obj.to_f
                        cell obj.to_f, :type => :float
                      end
                    }
                    csv << rowValues
                  }
                end
              end
              stmtSelect.close
          end
        }
        @connection.close()
        
      end
    end
  end
end
