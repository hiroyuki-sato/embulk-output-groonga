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

      class Schema
        def initialize(client, table_name, mappings)
          @client = client
          @table_name = table_name
          @mappings = mappings
          @taget_table = nil
          @columns = nil
        end

        def update(records)
          ensure_table
          ensure_columns

          nonexistent_columns = {}
          records.each do |record|
            record.each do |key, value|
              column = @columns[key]
              if column.nil?
                nonexistent_columns[key] ||= []
                nonexistent_columns[key] << value
              end
            end
          end

          nonexistent_columns.each do |name, values|
            @columns[name] = create_column(name, values)
          end
        end
      end
    end
  end
end
