require 'java'
require "~/.m2/repository/org/hsqldb/hsqldb/2.2.9/hsqldb-2.2.9.jar"
require 'rubygems'
require 'odf/spreadsheet'

module Spnt
  class JdbcReport
    @@jdbc_url = "jdbc:hsqldb:hsql://localhost/spnt-exp"
    @connection
    @report_path
    def initialize(aReportPath)
      @report_path = aReportPath#"./data/test.ods"
    end
    
    def is_numeric(object)
		true if Float(object) rescue false
	end



    def generate(exp_name)
      tableArr = %w{WORDSPOTINFOEXP WORDSPOTSAMPLEEXP WORDSPOTFOUNDEXP}
      columnMap = {}
      columnMap["WORDSPOTINFOEXP"] = "ID,FILENAME,PROCCESSINGLENGTH,EXPERIMENTSTARTED,EXPERIMENTENDED,AUDIOLENGTH".split(/,/)
      columnMap["WORDSPOTSAMPLEEXP"] = "ID,EKEY,FILENAME,MARKERLABEL,MARKERSTART,MARKEREND".split(/,/)
      columnMap["WORDSPOTFOUNDEXP"] = "ID,EKEY,FILENAME,MARKERLABEL,MARKERSTART,MARKEREND,FOUNDSTART,FOUNDEND,MFCCVALUE".split(/,/)
      orderByMap={}
      orderByMap["WORDSPOTINFOEXP"] = "FILENAME"
      orderByMap["WORDSPOTSAMPLEEXP"] = "FILENAME, MARKERSTART"
      orderByMap["WORDSPOTFOUNDEXP"] = "FILENAME, FOUNDSTART"

      ODF::Spreadsheet.file(@report_path) do
        @connection = java.sql.DriverManager.getConnection(@@jdbc_url, "sa", "")
        selectquery = "select distinct(markerlabel) from WORDSPOTSAMPLEEXP"
        stmtSelect = @connection.create_statement
        rsS = stmtSelect.execute_query(selectquery)
        table 'Info' do
          row {cell exp_name}
          row {
            p rsS
            while (rsS.next) do
              cell rsS.getObject(1)
            end
            stmtSelect.close
          }
        end
        tableArr.each{ |tableName|
          columnArr = columnMap[tableName]
          selectquery = "select #{columnArr.join(', ')} from #{tableName}  ORDER BY #{orderByMap[tableName]} "
          stmtSelect = @connection.create_statement
          rsS = stmtSelect.execute_query(selectquery)
          table tableName do
            row {
              columnArr.each{ |column|
                cell column
              }
            }
            while (rsS.next) do
              row {
                columnArr.each{ |column|
				  obj = rsS.getObject(column)
				  if obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil
					cell obj				
				  else
					cell obj.to_f, :type => :float
				  end
                  
                }
              }
            end
          end
          stmtSelect.close
        }
        @connection.close()
      end
    end
  end
end
