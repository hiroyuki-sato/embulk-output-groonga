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

      class TablesCreator
        def initialize(client, definitions)
          @client = client
          @definitions = definitions
        end

        def create
          return if @definitions.empty?

          table_list = @client.execute("table_list")
          @definitions.each do |definition|
            existing_table = table_list.find do |table|
              table.name == definition.name
            end
            if existing_table
              next unless definition.have_difference?(existing_table)
              # TODO: Is it OK?
              @client.execute("table_remove", "name" => definition.name)
            end

            @client.execute("table_create", definition.to_create_arguments)
            definition.indexes.each do |index|
              @client.execute("column_create", index.to_create_arguments)
            end
          end
        end
      end
    end
  end
end
