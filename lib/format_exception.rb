require "format_exception/version"
require "strscan"

##
# Simple exception formatter
#
# Provides utility methods for formatting an exception as a String.
#
# @example Classic format
#
#   require "format_exception"
#
#   def make_mistake
#     begin
#       raise "Deliberate mistake"
#     rescue Exception => ex
#       $stderr.puts FormatException.classic(ex)
#     end
#   end
#
#   make_mistake
#
#   # Prints:
#   #
#   # example.rb:7:in `make_mistake': Deliberate mistake (RuntimeError)
#   #         example.rb:13:in `<main>'
#
# @example Contextual clean format to Logger
#
#   require "logger"
#   require "format_exception"
#
#   logger = Logger.new($stderr)
#   begin
#     File.open("message.txt", "r") do |io|
#       puts io.read
#     end
#   rescue StandardError => ex
#     logger.error(FormatException[ex, "Printing welcome message"])
#   end
#
#   # Prints
#   #
#   # E, [2017-02-11T01:56:08.763049 #4302] ERROR -- : Printing welcome message: Errno::ENOENT: No such file or directory @ rb_sysopen - message.txt:
#   #         foo.rb:10:in `initialize'
#   #         foo.rb:10:in `open'
#   #         foo.rb:10:in `<main>'
#
# @example Contextual custom format
#
#   require "format_exception"
#
#   def make_mistake
#     begin
#       raise "Deliberate mistake"
#     rescue Exception => ex
#       $stderr.puts FormatException.format("%:m%C(\"%M\") at %f\n%R", ex, "Testing formatter")
#     end
#   end
#
#   make_mistake
#
#   # Prints
#   #
#   # Testing formatter: RuntimeError("Deliberate mistake") at example.rb:7:in `make_mistake'
#   #         example.rb:13:in `<main>'
#
module FormatException

  ##
  # The classic format (see {classic})
  #
  CLASSIC_FORMAT = "%f: %:m%M (%C)\n%R"

  ##
  # The clean format (see {clean})
  #
  CLEAN_FORMAT = "%:m%C: %M:\n%B"

  ##
  # Alias for {clean}
  #
  def self.[](e, context_message = nil)
    clean(e, context_message)
  end

  ##
  # The Ruby interpreter's default format
  #
  # Formats the exception exactly as the Ruby interpreter would if the exception
  # was uncaught. The first line includes the first line of the backtrace, and the
  # exception message and class name, with the rest of the backtrace on subsequent,
  # indented lines.
  #
  # If the +context_message+ is given, it is included on the first line, between
  # the first line of the backtrace and the exception message.
  #
  # @param [Exception] e
  #   the exception to format
  # @param [String] context_message
  #   the additional message to include in the formatted exception
  # @return [String] the formatted exception
  #
  def self.classic(e, context_message = nil)
    format(CLASSIC_FORMAT, e, context_message)
  end

  ##
  # The log-friendly format
  #
  # Formats the exception as the Rails logger would, with the exception class name
  # and message on the first line, with the backtrace on subsequent, indented lines.
  #
  # If the +context_message+ is given, it is prepended to the first line.
  #
  # @param [Exception] e
  #   the exception to format
  # @param [String] context_message
  #   the additional message to prepend to the formatted exception
  # @return [String] the formatted exception
  #
  def self.clean(e, context_message = nil)
    format(CLEAN_FORMAT, e, context_message)
  end

  ##
  # Format exception as per printf-like format specifier
  #
  # The following format specifiers are supported:
  #
  # * +%C+  - the exception class name
  # * +%M+  - the exception message
  # * +%m+  - the context message if given
  # * +%:m+ - the context message, a colon and a space, if the context message is given
  # * +%f+  - the first line of the backtrace, unindented
  # * +%r+  - all lines of the backtrace but the first, newline-separated, unindented
  # * +%R+  - all lines of the backtrace but the first, newline-separated, indented
  # * +%b+  - all lines of the backtrace, newline-separated, unindented
  # * +%B+  - all lines of the backtrace, newline-separated, indented
  # * +%%+  - a literal +%+
  #
  def self.format(f, e, c = nil)
    scanner = StringScanner.new(f)
    formatted = ""
    loop do
      formatted << scanner.scan(/[^%]*/)
      token = scanner.scan(/%:?./)
      case token
      when "%C" then formatted << e.class.to_s
      when "%M" then formatted << e.message
      when "%m" then formatted << c if c
      when "%:m" then formatted << "#{c}: " if c
      when "%f" then formatted << e.backtrace.first
      when "%r" then formatted << e.backtrace.drop(1).join("\n")
      when "%R" then formatted << ("\t" + e.backtrace.drop(1).join("\n\t"))
      when "%b" then formatted << e.backtrace.join("\n")
      when "%B" then formatted << ("\t" + e.backtrace.join("\n\t"))
      when "%%" then formatted << "%"
      when nil then break
      else
        raise ArgumentError, "unknown format specifier '#{scanner.matched}'"
      end
      break if scanner.eos?
    end
    formatted
  end
end
