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
    if context_message
      "#{context_message}: " + clean(e)
    else
      clean(e)
    end
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
  # @return [String] the formatted exception
  #
  def self.classic(e)
    "#{e.backtrace.first}: #{e.message} (#{e.class})\n\t" + e.backtrace.drop(1).join("\n\t")
  end

  ##
  # The log-friendly format
  #
  # Formats the exception as the Rails logger would, with the exception class name
  # and message on the first line, with the backtrace on subsequent, indented lines.
  #
  # @param [Exception] e
  #   the exception to format
  # @return [String] the formatted exception
  #
  def self.clean(e)
    "#{e.class}: #{e.message}:\n\t" + e.backtrace.join("\n\t")
  end

end
