# -*- coding: utf-8 -*-
#
# Copyright (C) 2012-2014  Kouhei Sutou <kou@clear-code.com>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License version 2.1 as published by the Free Software Foundation.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

module Embulk
  module Output
    module Groonga

      class NetworkClient < BaseClient
        include Configurable

        config_param :host, :string, :default => nil
        config_param :port, :integer, :default => nil

        def initialize(protocol)
          super()
          @protocol = protocol
        end

        def start
          @client = nil
        end

        def shutdown
          return if @client.nil?
          @client.close
        end

        def execute(name, arguments={})
          command = build_command(name, arguments)
          @client ||= Groonga::Client.new(:protocol => @protocol,
                                          :host     => @host,
                                          :port     => @port,
                                          :backend  => :synchronous)
          response = nil
          begin
            response = @client.execute(command)
          rescue Groonga::Client::Error
            $log.error("[output][groonga][error]",
                       :protocol => @protocol,
                       :host => @host,
                       :port => @port,
                       :command_name => name)
            raise
          end
          unless response.success?
            $log.error("[output][groonga][error]",
                       :status_code => response.status_code,
                       :message => response.message)
          end
          response
        end
      end

    end
  end
end
