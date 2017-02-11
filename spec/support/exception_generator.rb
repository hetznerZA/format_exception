class ExceptionGenerator

  def self.generate_error(exception_class, message)
    request_error(exception_class, message)
  end

  def self.request_error(exception_class, message)
    begin
      raise_error(exception_class, message)
    rescue exception_class => ex
      ex
    end
  end

  def self.raise_error(exception_class, message)
    raise exception_class, message
  end

end

