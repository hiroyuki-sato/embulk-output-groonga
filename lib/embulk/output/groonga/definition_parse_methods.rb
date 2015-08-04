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

      module DefinitionParseMethods
        private
        def parse_flags(flags)
          if flags.is_a?(Array)
            flags
          else
            flags.strip.split(/\s*\|\s*/)
          end
        end

        def parse_items(items)
          if items.is_a?(Array)
            items
          else
            items.strip.split(/\s*,\s*/)
          end
        end
      end
    end
  end
end
