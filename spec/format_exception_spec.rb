require "spec_helper"

require "format_exception"

describe FormatException do

  subject { described_class }

  context "given an exception" do

    let(:exception_class) { TestException }
    let(:exception_message) { "forced error" }
    let(:exception) { ExceptionGenerator.request_error(exception_class, exception_message) }

    describe "#[ex]" do
      let(:formatted) { subject[exception] }

      include_examples "clean format"
    end

    describe "#[ex, context_message]" do
      let(:context_message) { "While testing" }
      let(:formatted) { subject[exception, context_message] }

      it "includes the message at the beginning of the first line" do
        first_line = formatted.split("\n").first
        expect(first_line).to match(/^#{context_message}: /)
      end

      include_examples "clean format"
    end

    describe "#clean(ex)" do
      let(:formatted) { subject.clean(exception) }

      include_examples "clean format"
    end

    describe "#classic(ex)" do
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
    end

  end

end
