RSpec.shared_examples "clean format" do

  it "includes the exception class name on the first line" do
    first_line = formatted.split("\n").first
    expect(first_line).to match(/#{exception_class}: /)
  end

  it "includes the exception message at the end of the first line" do
    first_line = formatted.split("\n").first
    expect(first_line).to match(/#{exception_message}:$/)
  end

  it "includes the first line of the backtrace on the second line" do
    second_line = formatted.split("\n")[1]
    expect(second_line).to match(/\.rb:\d+:in `raise_error'/)
  end

  it "includes the second line of the backtrace on the third line" do
    third_line = formatted.split("\n")[2]
    expect(third_line).to match(/\.rb:\d+:in `request_error'/)
  end

  it "indents every line of the backtrace" do
    backtrace_lines = formatted.split("\n").drop(1)
    expect(backtrace_lines).to all( start_with("\t") )
  end

  it "does not indent the first line" do
    first_line = formatted.split("\n").first
    expect(first_line).to_not start_with("\t")
  end

end
