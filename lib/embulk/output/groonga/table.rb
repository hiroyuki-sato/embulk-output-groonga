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

      class Table
        attr_reader :name
        attr_reader :flags
        attr_reader :domain
        attr_reader :range
        attr_reader :default_tokenizer
        attr_reader :normalizer
        attr_reader :token_filters
        def initialize(name, options={})
          @name = name
          @flags             = options[:flags]
          @domain            = options[:domain]
          @range             = options[:range]
          @default_tokenizer = options[:default_tokenizer]
          @normalizer        = options[:normalizer]
          @token_filters     = options[:token_filters]
        end
      end

    end
  end
end
