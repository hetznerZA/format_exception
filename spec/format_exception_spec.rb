require "spec_helper"

require "format_exception"

describe FormatException do

  subject { described_class }

  context "given an exception" do

    let(:context_message) { "While testing" }
    let(:exception_class) { TestException }
    let(:exception_message) { "forced error" }
    let(:exception) { ExceptionGenerator.generate_error(exception_class, exception_message) }

    describe "#[ex, context_message = nil]" do
      let(:formatted) { subject[exception, context_message] }

      include_examples "clean format"
    end

    describe "#clean(ex, context_message = nil)" do
      let(:formatted) { subject.clean(exception, context_message) }

      include_examples "clean format"
    end

    describe "#classic(ex, context_message = nil)" do
      let(:formatted) { subject.classic(exception) }

      it "includes the exception class name at the end of the first line" do
        first_line = formatted.split("\n").first
        expect(first_line).to match(/\(#{exception_class}\)$/)
      end

      it "includes the exception message on the first line" do
        first_line = formatted.split("\n").first
        expect(first_line).to match(/#{exception_message}/)
      end

      it "includes the first line of the backtrace on the first line" do
        first_line = formatted.split("\n").first
        expect(first_line).to match(/\.rb:\d+:in `raise_error'/)
      end

      it "includes the second line of the backtrace on the second line" do
        second_line = formatted.split("\n")[1]
        expect(second_line).to match(/\.rb:\d+:in `request_error'/)
      end

      it "indents every line of the backtrace except the first line" do
        backtrace_lines = formatted.split("\n").drop(1)
        expect(backtrace_lines).to all( start_with("\t") )
      end

      it "does not indent the first line" do
        first_line = formatted.split("\n").first
        expect(first_line).to_not start_with("\t")
      end

      context "with a context message" do
        let(:context_message) { "While testing" }
        let(:formatted) { subject.classic(exception, context_message) }

        it "includes the context after the first line of the backtrace on the first line" do
          first_line = formatted.split("\n").first
          expect(first_line).to match(/\.rb:\d+:in `\w+': #{context_message}: /)
        end
      end
    end

    describe "#format(format, ex, context_message = nil)" do

      it "replaces %% in the format with a single %" do
        expect(subject.format("%%", exception)).to eql("%")
      end

      it "raises an ArgumentError when the format includes an unrecognized specifier" do
        expect { subject.format("%s", exception) }.to raise_error(ArgumentError, /unknown format specifier '%s'/)
      end

      it "replaces %C in the format with the exception class name" do
        expect(subject.format("%C", exception)).to eql(exception_class.to_s)
      end

      it "replaces %M in the format with the exception message name" do
        expect(subject.format("%M", exception)).to eql(exception_message)
      end

      it "replaces %m in the format with the context message" do
        expect(subject.format("%m", exception, context_message)).to eql(context_message)
      end

      it "replaces %m in the format with nothing if no context message is given" do
        expect(subject.format("%m", exception)).to eql("")
      end

      it "replaces %:m in the format with the context message, a colon and a space if the context message is given" do
        expect(subject.format("%:m", exception, context_message)).to eql("#{context_message}: ")
      end

      it "replaces %:m in the format with nothing if no context message is given" do
        expect(subject.format("(%:m)", exception)).to eql("()")
      end

      it "replaces %f in the format with the first line of exception backtrace" do
        expect(subject.format("%f", exception)).to match(/\.rb:\d+:in `raise_error'$/)
      end

      it "replaces %R in the format with all but the first line of the exception backtrace (indented)" do
        lines = subject.format("%R", exception).split("\n")
        expect(lines[0]).to match(/^\t.*\.rb:\d+:in `request_error'$/)
        expect(lines[1]).to match(/^\t.*\.rb:\d+:in `generate_error'$/)
      end

      it "replaces %r in the format with all but the first line of the exception backtrace (not indented)" do
        lines = subject.format("%r", exception).split("\n")
        expect(lines[0]).to match(/^[^\t].*\.rb:\d+:in `request_error'$/)
        expect(lines[1]).to match(/^[^\t].*\.rb:\d+:in `generate_error'$/)
      end

      it "replaces %b in the format with all lines of the exception backtrace (not indented)" do
        lines = subject.format("%b", exception).split("\n")
        expect(lines[0]).to match(/^[^\t].*\.rb:\d+:in `raise_error'$/)
        expect(lines[1]).to match(/^[^\t].*\.rb:\d+:in `request_error'$/)
      end

      it "replaces %B in the format with all lines of the exception backtrace (indented)" do
        lines = subject.format("%B", exception).split("\n")
        expect(lines[0]).to match(/^\t.*\.rb:\d+:in `raise_error'$/)
        expect(lines[1]).to match(/^\t.*\.rb:\d+:in `request_error'$/)
      end

    end

  end

end
