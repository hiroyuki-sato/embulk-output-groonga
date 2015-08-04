require 'groonga/client'
require 'embulk/output/groonga/base_client.rb'
require 'embulk/output/groonga/column.rb'
require 'embulk/output/groonga/command_client.rb'
require 'embulk/output/groonga/definition_parse_methods.rb'
require 'embulk/output/groonga/index_definitions.rb'
require 'embulk/output/groonga/network_cilent.rb'
require 'embulk/output/groonga/schema.rb'
require 'embulk/output/groonga/table.rb'
require 'embulk/output/groonga/table_definition.rb'
require 'embulk/output/groonga/tables_creator.rb'
require 'embulk/output/groonga/type_gusser.rb'

module Embulk
  module Output

    FLUSH_SIZE = 1_000
    class GroongaOutputPlugin < OutputPlugin
      Plugin.register_output("groonga", self)

      def self.transaction(config, schema, count, &control)
        # configuration code:
        task = {
          "host" => config.param("host", :string),
          "port" => config.param("port", :integer, default: 10041),
          "protocol" => config.param("protocol", :string, default: 'http'),
          "key_column" => config.param("key_column",:string),
          "table" => config.param("table",:string),
#          "create_table" => config.param("create_table",:string)
        }
        prot = task['protocol']
        raise RuntimeError,"Unknown protocol #{prot}. supported protocol: gqtp, http" unless %w[gqtp http].include?(prot)

        # resumable output:
        # resume(task, schema, count, &control)

        # non-resumable output:
        commit_reports = yield(task)
        next_config_diff = {}
        return next_config_diff
      end

      #def self.resume(task, schema, count, &control)
      #  commit_reports = yield(task)
      #
      #  next_config_diff = {}
      #  return next_config_diff
      #end

      def init
        # initialization code:
        host = task["host"]
        port = task["port"]
        protocol = task["protocol"].to_sym
        @client = Groonga::Client.open({:host => host,
                                        :port => port,
                                        :protocol => protocol})
        @key_column = task["key_column"]
        @out_table = task["table"]

#        create_table
      end

      def close
        @client.close
      end

      def add(page)
        # output code:
        records = []
        idx = 0
        page.each_with_index do |record,idx|
          hash = Hash[schema.names.zip(record)]
          v = hash.delete(@key_column)
          hash['_key'] = v
          records << hash
          if( idx > 0 && idx % FLUSH_SIZE == 0 )
            ret = @client.load({:table => @out_table,
                                :values => records })
            records.clear
          end
        end
        if( records.size > 0 )
          ret = @client.load({:table => @out_table,
                              :values => records })
        end
      end

      def finish
      end

      def abort
      end

      def commit
        commit_report = {}
        return commit_report
      end
      private
      def table_names
        # TODO Error check
        @client.table_list.map{ |x| x['name'] }
      end

      def table_exist?(name)
        # TODO Error check
        table_names.include?(name)
      end

      def create_table
        return if table_exist?(@out_table)
        create_table = @task['create_table']

        # TODO Error check

        @client.execute(create_table)

      end

    end

  end
end
