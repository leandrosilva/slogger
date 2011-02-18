module Slogger
  #
  # The wrapper for standard Ruby Syslog library.
  #
  class Logger
    LEVEL = {
      :crit    => 0,
      :emerg   => 1,
      :alert   => 2,
      :err     => 3,
      :warning => 4,
      :notice  => 5,
      :info    => 6,
      :debug   => 7
    }
    
    FACILITY = {
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
    
    attr_reader :app_name, :level, :facility

    #
    # To build a Slogger::Logger instance.
    #
    # +app_name+::  The appliaction name to be logged
    # +level+::     The log level: :crit, :emerg, :alert, :err, :warning, :notice,
    #                 :info, or :debug.
    # +facility+::  A typical syslog facility: :user, :mail, :daemon, :auth,
    #                 :syslog, :lpr, :news, :uucp, :cron, :authpriv, :ftp,
    #                 :local0, :local1, :local2, :local3, :local4, :local5,
    #                 :local6, or :local7
    #
    # Raises an ArgumentError if app_name, level, or facility is nil.
    #
    def initialize(app_name, level, facility)
      raise ArgumentError, "The 'app_name' parameter is required" unless app_name
      raise ArgumentError, "The 'level' parameter is required" unless level
      raise ArgumentError, "The 'facility' parameter is required" unless facility
      
      @app_name = app_name
      @level = level
      @level_as_int = LEVEL[level]
      @facility = facility
      @facility_as_int = FACILITY[facility]
    end
    
    LEVEL.each_key do |level|
      define_method level do |message, &block|
        log(level, message, &block)
      end
    end
    
    private
    
    def log(level, message, &block)
      return if LEVEL[level] > @level_as_int

      if block_given?
        began_at = Time.now
        
        yield
        
        now = Time.now
        end_at = now - began_at
        message = "[#{end_at}s] #{message}"
      end
      
      Syslog.open(@app_name, Syslog::LOG_PID, @facility_as_int) { |s| s.send level, message }
    end
  end
end
