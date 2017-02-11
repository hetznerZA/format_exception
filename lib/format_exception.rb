require "format_exception/version"

##
# Simple exception formatter
#
# Provides utility methods for formatting an exception as a String.
#
# @example The contextual clean format
#
#   require "logger"
#   require "format_exception"
#
#   logger = Logger.new($stderr)
#   begin
#     File.open("message.txt", "r") do |io|
#       puts io.read
#     end
#   rescue IOError => ex
#     logger.error(FormatException[ex, "Printing welcome message"])
#   end
#
#   # Prints
#   #
#   # E, [2017-02-11T01:56:08.763049 #4302] ERROR -- : Printing welcome message: Errno::ENOENT: No such file or directory @ rb_sysopen - message.txt:
#   #	foo.rb:10:in `initialize'
#   #	foo.rb:10:in `open'
#   #	foo.rb:10:in `<main>'
#
module FormatException

  CLASSIC_FORMAT = "%:m%f: %M (%C)\n%R"
  CLEAN_FORMAT = "%:m%C: %M:\n%B"

  ##
  # The contextual clean format
  #
  # Format the exception as per {clean}, but with an optional +context_message+
  # prepended to the first line.
  #
  # @param [Exception] e
  #   the exception to format
  # @param [String] context_message
  #   the additional message to prepend to the formatted exception
  # @return [String] the formatted exception
  #
  def self.[](e, context_message = nil)
    format(CLEAN_FORMAT, e, context_message)
  end

  ##
  # The Ruby interpreter's default format
  #
  # Formats the exception exactly as the Ruby interpreter would if the exception
  # was uncaught. The first line includes the first line of the backtrace, and the
  # exception class name and message, with the rest of the backtrace on subsequent,
  # indented lines.
  #
  # @param [Exception] e
  #   the exception to format
  # @param [String] context_message
  #   the additional message to prepend to the formatted exception
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
  # @param [Exception] e
  #   the exception to format
  # @param [String] context_message
  #   the additional message to prepend to the formatted exception
  # @return [String] the formatted exception
  #
  def self.clean(e, context_message = nil)
    format(CLEAN_FORMAT, e, context_message)
  end

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
