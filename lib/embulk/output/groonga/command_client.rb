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

      class CommandClient < BaseClient
        include Configurable

        config_param :groonga, :string, :default => "groonga"
        config_param :database, :string
        config_param :arguments, :default => [] do |value|
          Shellwords.split(value)
        end

        def initialize
          super
        end

        def configure(conf)
          super
        end

        def start
          run_groonga
        end

        def shutdown
          @input.close
          read_output("shutdown")
          @output.close
          @error.close
          Process.waitpid(@pid)
        end

        def execute(name, arguments={})
          command = build_command(name, arguments)
          body = nil
          if command.name == "load"
            body = command.arguments.delete(:values)
          end
          uri = command.to_uri_format
          @input.write("#{uri}\n")
          if body
            body.each_line do |line|
              @input.write("#{line}\n")
            end
          end
          @input.flush
          read_output(uri)
        end

        private
        def run_groonga
          env = {}
          input = IO.pipe("ASCII-8BIT")
          output = IO.pipe("ASCII-8BIT")
          error = IO.pipe("ASCII-8BIT")
          input_fd = input[0].to_i
          output_fd = output[1].to_i
          options = {
            input_fd => input_fd,
            output_fd => output_fd,
            :err => error[1],
          }
          arguments = @arguments
          arguments += [
            "--input-fd", input_fd.to_s,
            "--output-fd", output_fd.to_s,
          ]
          unless File.exist?(@database)
            FileUtils.mkdir_p(File.dirname(@database))
            arguments << "-n"
          end
          arguments << @database
          @pid = spawn(env, @groonga, *arguments, options)
          input[0].close
          @input = input[1]
          output[1].close
          @output = output[0]
          error[1].close
          @error = error[0]
        end

        def read_output(context)
          output_message = ""
          error_message = ""

          loop do
            readables = IO.select([@output, @error], nil, nil, 0)
            break if readables.nil?

            readables.each do |readable|
              case readable
              when @output
                output_message << @output.gets
              when @error
                error_message << @error.gets
              end
            end
          end

          unless output_message.empty?
            $log.debug("[output][groonga][output]",
                       :context => context,
                       :message => output_message)
          end
          unless error_message.empty?
            $log.error("[output][groonga][error]",
                       :context => context,
                       :message => error_message)
          end
        end
      end

    end
  end
end
