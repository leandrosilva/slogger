module Slogger
  class Base
    attr_reader :app_name, :severity, :facility
    
    #
    # To build a Slogger::Base instance.
    #
    # +app_name+::  The appliaction name to be logged
    # +severity+::  The log severity
    # +facility+::  A typical syslog facility
    #
    # Raises an ArgumentError if app_name, severity, or facility is nil.
    #
    def initialize(app_name, severity, facility, specialized_logger)
      raise_argument_error_to_required_parameter "app_name" unless app_name
      raise_argument_error_to_required_parameter "severity" unless severity
      raise_argument_error_to_required_parameter "facility" unless facility

      raise_argument_error_to_invalid_parameter "severity", "SEVERITIES" unless specialized_logger::SEVERITIES[severity]
      raise_argument_error_to_invalid_parameter "facility", "FACILITIES" unless specialized_logger::FACILITIES[facility]

      @app_name = app_name
      @severity = severity
      @facility = facility
      @specialized_logger = specialized_logger
    end

    def severity=(value)
      raise_argument_error_to_invalid_parameter "severity", "FACILITIES" unless @specialized_logger::SEVERITIES[value]
      
      @severity = value
    end

    def raise_argument_error_to_required_parameter(param)
      raise ArgumentError, "The '#{param}' parameter is required."
    end

    def raise_argument_error_to_invalid_parameter(param, options)
      raise ArgumentError, "The '#{param}' parameter is invalid. Inspect the #{options} constant to know the options."
    end
  end
end
