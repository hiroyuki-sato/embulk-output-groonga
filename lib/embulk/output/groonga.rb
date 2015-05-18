require 'groonga/client'
require 'pp'

module Embulk
  module Output

    class GroongaOutputPlugin < OutputPlugin
      Plugin.register_output("groonga", self)

      def self.transaction(config, schema, count, &control)
        # configuration code:
        task = {
          "host" => config.param("host", :string),
          "port" => config.param("port", :integer),
          "protocol" => config.param("protocol", :string),
          "key_column" => config.param("key_column",:string, default: 'gqtp'),
          "table" => config.param("table",:string),
          "create_table" => config.param("create_table",:string)
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

        create_table
      end

      def close
        @client.close
      end

      def add(page)
        # output code:
        page.each do |record|
          hash = Hash[schema.names.zip(record)]
          v = hash.delete(@key_column)
          hash['_key'] = v
          ret = @client.load({:table => @out_table,
                        :values => [hash] })
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

      def table_exit?(name)
        # TODO Error check
        table_names.include?(name)
      end

      def create_table
        return if table_exit?(@out_table)
        create_table = @task['create_table']

        # TODO Error check

        @client.execute(create_table)

      end

    end

  end
end
