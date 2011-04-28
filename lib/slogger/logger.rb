module Slogger
  #
  # The wrapper for standard Ruby Syslog library.
  #
  class Logger
    
    #
    # Syslog Message Severities
    #
    # - Emergency: system is unusable
    # - Alert: action must be taken immediately
    # - Critical: critical conditions
    # - Error: error conditions
    # - Warning: warning conditions
    # - Notice: normal but significant condition
    # - Informational: informational messages
    # - Debug: debug-level messages
    #
    SEVERITY = {
      :emerg   => Syslog::LOG_EMERG,
      :alert   => Syslog::LOG_ALERT,
      :crit    => Syslog::LOG_CRIT,
      :err     => Syslog::LOG_ERR,
      :warning => Syslog::LOG_WARNING,
      :notice  => Syslog::LOG_NOTICE,
      :info    => Syslog::LOG_INFO,
      :debug   => Syslog::LOG_DEBUG
    }
    
    #
    # Syslog Message Facilities
    #
    # - kernel messages
    # - user-level messages
    # - mail system
    # - system daemons
    # - security/authorization messages
    # - messages generated internally by syslogd
    # - line printer subsystem
    # - network news subsystem
    # - UUCP subsystem
    # - clock daemon
    # - security/authorization messages
    # - FTP daemon
    # - NTP subsystem
    # - log audit
    # - log alert
    # - clock daemon (note 2)
    # - local use 0  (local0)
    # - local use 1  (local1)
    # - local use 2  (local2)
    # - local use 3  (local3)
    # - local use 4  (local4)
    # - local use 5  (local5)
    # - local use 6  (local6)
    # - local use 7  (local7)
    #           
    FACILITY = {
      :kernel   => Syslog::LOG_KERN,
      :user     => Syslog::LOG_USER,
      :mail     => Syslog::LOG_MAIL,
      :daemon   => Syslog::LOG_DAEMON,
      :auth     => Syslog::LOG_AUTH,
      :syslog   => Syslog::LOG_SYSLOG,
      :lpr      => Syslog::LOG_LPR,
      :news     => Syslog::LOG_NEWS,
      :uucp     => Syslog::LOG_UUCP,
      :cron     => Syslog::LOG_CRON,
      :authpriv => Syslog::LOG_AUTHPRIV,
      :ftp      => Syslog::LOG_FTP,
      :local0   => Syslog::LOG_LOCAL0,
      :local1   => Syslog::LOG_LOCAL1,
      :local2   => Syslog::LOG_LOCAL2,
      :local3   => Syslog::LOG_LOCAL3,
      :local4   => Syslog::LOG_LOCAL4,
      :local5   => Syslog::LOG_LOCAL5,
      :local6   => Syslog::LOG_LOCAL6,
      :local7   => Syslog::LOG_LOCAL7
    }
    
    attr_reader :app_name, :severity, :facility

    #
    # To build a Slogger::Logger instance.
    #
    # +app_name+::  The appliaction name to be logged
    # +severity+::  The log severity: :emerg, :alert, :crit, :err, :warning, :notice,
    #                 :info, or :debug. It can be changed at anytime.
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
      @severity_as_int = SEVERITY[severity]
      @facility = facility
      @facility_as_int = FACILITY[facility]
    end
    
    SEVERITY.each_key do |severity|
      define_method severity do |message, &block|
        log(severity, message, &block)
      end
    end
    
    def severity=(value)
      raise_argument_error_to_invalid_parameter "severity", "SEVERITY" unless SEVERITY[value]
      
      @severity = value
      @severity_as_int = SEVERITY[value]
    end
    
    private
    
    def log(severity, message, &block)
      return if SEVERITY[severity] > @severity_as_int

      if block_given?
        # TODO use Benchmark.measure
        began_at = Time.now
        
        yield
        
        now = Time.now
        end_at = now - began_at
        message = "[#{end_at}s] #{message}"
      end
      
      Syslog.open(@app_name, Syslog::LOG_PID, @facility_as_int) { |s| s.send severity, message }
    end
    
    def raise_argument_error_to_required_parameter(param)
      raise ArgumentError, "The '#{param}' parameter is required."
    end

    def raise_argument_error_to_invalid_parameter(param, options)
      raise ArgumentError, "The '#{param}' parameter is invalid. Inspect the #{options} constant to know the options."
    end
  end
end
