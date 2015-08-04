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

      class TableDefinition
        include DefinitionParseMethods

        def initialize(raw)
          @raw = raw
        end

        def name
          @raw[:name]
        end

        def flags
          parse_flags(@raw[:flags] || "TABLE_NO_KEY")
        end

        def key_type
          @raw[:key_type]
        end

        def default_tokenizer
          @raw[:default_tokenizer]
        end

        def token_filters
          parse_items(@raw[:token_filters] || "")
        end

        def normalizer
          @raw[:normalizer]
        end

        def indexes
          (@raw[:indexes] || []).collect do |raw|
            IndexDefinition.new(self, raw)
          end
        end

        def have_difference?(table)
          return true if table.name != name

          table_flags = (parse_flags(table.flags) - ["PERSISTENT"])
          return true if table_flags.sort != flags.sort

          return true if table.domain != key_type

          return true if table.default_tokenizer != default_tokenizer

          # TODO
          # return true if table.token_filters.sort != token_filters.sort

          return true if table.normalizer != normalizer

          false
        end

        def to_create_arguments
          arguments = {
            "name" => name,
            "flags" => flags.join("|"),
            "key_type" => key_type,
            "default_tokenizer" => default_tokenizer,
            # TODO
            # "token_filters" => token_filters.join("|"),
            "normalizer" => normalizer,
          }
          arguments.keys.each do |key|
            value = arguments[key]
            arguments.delete(key) if value.nil? or value.empty?
          end
          arguments
        end

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
end