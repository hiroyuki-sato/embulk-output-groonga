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

      class TypeGuesser
        def initialize(sample_values)
          @sample_values = sample_values
        end

        def guess
          return "Time"          if time_values?
          return "Int32"         if int32_values?
          return "Int64"         if int64_values?
          return "Float"         if float_values?
          return "WGS84GeoPoint" if geo_point_values?
          return "LongText"      if long_text_values?
          return "Text"          if text_values?

          "ShortText"
        end

        def vector?
          @sample_values.any? do |sample_value|
            sample_value.is_a?(Array)
          end
        end

        private
        def integer_value?(value)
          case value
          when String
            begin
              Integer(value)
              true
            rescue ArgumentError
              false
            end
          when Integer
            true
          else
            false
          end
        end

        def time_values?
          now = Time.now.to_i
          year_in_seconds = 365 * 24 * 60 * 60
          window = 10 * year_in_seconds
          new = now + window
          old = now - window
          recent_range = old..new
          @sample_values.all? do |sample_value|
            integer_value?(sample_value) and
              recent_range.cover?(Integer(sample_value))
          end
        end

        def int32_values?
          int32_min = -(2 ** 31)
          int32_max = 2 ** 31 - 1
          range = int32_min..int32_max
          @sample_values.all? do |sample_value|
            integer_value?(sample_value) and
              range.cover?(Integer(sample_value))
          end
        end

        def int64_values?
          @sample_values.all? do |sample_value|
            integer_value?(sample_value)
          end
        end

        def float_value?(value)
          case value
          when String
            begin
              Float(value)
              true
            rescue ArgumentError
              false
            end
          when Float
            true
          else
            false
          end
        end

        def float_values?
          @sample_values.all? do |sample_value|
            float_value?(sample_value)
          end
        end

        def geo_point_values?
          @sample_values.all? do |sample_value|
            sample_value.is_a?(String) and
              /\A-?\d+(?:\.\d+)[,x]-?\d+(?:\.\d+)\z/ =~ sample_value
          end
        end

        MAX_SHORT_TEXT_SIZE = 2 ** 12
        MAX_TEXT_SIZE       = 2 ** 16
        def text_values?
          @sample_values.any? do |sample_value|
            sample_value.is_a?(String) and
              sample_value.bytesize > MAX_SHORT_TEXT_SIZE
          end
        end

        def long_text_values?
          @sample_values.any? do |sample_value|
            sample_value.is_a?(String) and
              sample_value.bytesize > MAX_TEXT_SIZE
          end
        end
      end

    end
  end
end
