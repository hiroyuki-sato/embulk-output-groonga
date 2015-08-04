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
      class IndexDefinition
        include DefinitionParseMethods

        def initialize(table, raw)
          @table = table
          @raw = raw
        end

        def name
          @raw[:name]
        end

        def source_table
          @raw[:source_table]
        end

        def source_columns
          parse_items(@raw[:source_columns])
        end

        def flags
          _flags = ["COLUMN_INDEX"]
          _flags << "WITH_POSITION" if @table.default_tokenizer
          _flags << "WITH_SECTION" if source_columns.size >= 2
          _flags
        end

        def to_create_arguments
          {
            "table"  => @table.name,
            "name"   => name,
            "flags"  => flags.join("|"),
            "type"   => source_table,
            "source" => source_columns.join(","),
          }
        end
      end
    end
  end
end
