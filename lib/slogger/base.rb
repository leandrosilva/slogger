require 'thread'

module Slogger
  class Base
    
    #
    # Syslog Message Severities:
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
    SYSLOG_SEVERITIES = {
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
    # Syslog Message Facilities:
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
    SYSLOG_FACILITIES = {
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
    # To build a Slogger::Base instance.
    #
    # +app_name+::                The appliaction name to be logged
    # +severity+::                The log severity.
    # +facility+::                A typical syslog facility
    # +custom_severity_levels+::  To be used by children classes. It defaults to
    #                               Slogger::Base::SYSLOG_SEVERITIES.
    #
    # Raises an ArgumentError if app_name, severity, or facility is nil.
    #
    def initialize(app_name, severity, facility, custom_severity_levels=SYSLOG_SEVERITIES)
      raise_argument_error_to_required_parameter "app_name" unless app_name
      raise_argument_error_to_required_parameter "severity" unless severity
      raise_argument_error_to_required_parameter "facility" unless facility

      raise_argument_error_to_invalid_parameter "severity", "SEVERITIES" unless custom_severity_levels[severity]
      raise_argument_error_to_invalid_parameter "facility", "FACILITIES" unless SYSLOG_FACILITIES[facility]

      @app_name = app_name
      @severity = severity
      @severity_as_int = custom_severity_levels[severity]
      @facility = facility
      @facility_as_int = SYSLOG_FACILITIES[facility]
      @custom_severity_levels = custom_severity_levels
      @mutex = Mutex.new
    end

    def severity=(value)
      raise_argument_error_to_invalid_parameter "severity", "SEVERITIES" unless @custom_severity_levels[value]
      
      @severity = value
      @severity_as_int = @custom_severity_levels[severity]
    end

    def log(severity, message, &block)
      return if SYSLOG_SEVERITIES[severity] > @severity_as_int

      if block_given?
        benchmark = Benchmark.measure &block
        message = "[time: #{benchmark.real}] #{message}"
      end
      
      @mutex.synchronize do
        Syslog.open(@app_name, Syslog::LOG_PID, @facility_as_int) { |s| s.send severity, '%s', message }
      end
    end

    def raise_argument_error_to_required_parameter(param)
      raise ArgumentError, "The '#{param}' parameter is required."
    end

    def raise_argument_error_to_invalid_parameter(param, options)
      raise ArgumentError, "The '#{param}' parameter is invalid. Inspect the #{options} constant to know the options."
    end
  end
end
