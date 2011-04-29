module Slogger
  #
  # A delegate class to make possible to use Slogger in application which by
  # default use standard Ruby Logger. It just exposes the same API of standard
  # Ruby Logger class.
  #
  class CommonLogger
    
    #
    # A bridge between standard Logger and Syslog
    #
    SEVERITY = {
      :unknow  => :alert,
      :fatal   => :err,
      :error   => :warning,
      :warning => :notice,
      :info    => :info,
      :debug   => :debug
    }
    
    FACILITY = ::Slogger::Logger::FACILITY
    
    attr_reader :app_name, :severity, :facility

    #
    # To build a Slogger::CommonLogger instance.
    #
    # +app_name+::  The appliaction name to be logged
    # +severity+::  The log severity (according to standard Ruby Logger): :unknow, :fatal,
    #                 :error, :warning, :info, or :debug. It can be changed at anytime.
    # +facility+::  A typical syslog facility: :kernel, :user, :mail, :daemon, :auth,
    #                 :syslog, :lpr, :news, :uucp, :cron, :authpriv, :ftp,
    #                 :local0, :local1, :local2, :local3, :local4, :local5,
    #                 :local6, or :local7
    #
    # Raises an ArgumentError if app_name, severity, or facility is nil.
    #
    def initialize(app_name, severity, facility)
      raise_argument_error_to_required_parameter "app_name" unless app_name
      raise_argument_error_to_required_parameter "severity" unless severity
      raise_argument_error_to_required_parameter "facility" unless facility

      raise_argument_error_to_invalid_parameter "severity", "SEVERITY" unless SEVERITY[severity]
      raise_argument_error_to_invalid_parameter "facility", "FACILITY" unless FACILITY[facility]
      
      @app_name = app_name
      @severity = severity
      @facility = facility
      
      @syslogger = ::Slogger::Logger.new @app_name, SEVERITY[@severity], @facility
    end

    SEVERITY.each_key do |severity|
      define_method severity do |message, &block|
        @syslogger.send SEVERITY[severity], "StLg - #{message}", &block
      end
    end
    
    def severity=(value)
      raise_argument_error_to_invalid_parameter "severity", "SEVERITY" unless SEVERITY[value]
      
      @severity = value
      @severity_as_int = SEVERITY[value]
    end
    
    def raise_argument_error_to_required_parameter(param)
      raise ArgumentError, "The '#{param}' parameter is required."
    end

    def raise_argument_error_to_invalid_parameter(param, options)
      raise ArgumentError, "The '#{param}' parameter is invalid. Inspect the #{options} constant to know the options."
    end
  end
end
