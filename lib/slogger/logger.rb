module Slogger
  #
  # The wrapper for standard Ruby Syslog library.
  #
  # Sample:
  #
  # slogger = Slogger::Logger.new "sample_app", :info, :local0 
  # slogger.info "A good info"
  # slogger.debug "A deep info (oops! it'll not be logged)"
  #
  class Logger < Base

    #
    # Just sugars
    #
    SEVERITIES = ::Slogger::Base::SYSLOG_SEVERITIES
    FACILITIES = ::Slogger::Base::SYSLOG_FACILITIES
    
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
      super app_name, severity, facility
    end
    
    SEVERITIES.each_key do |severity|
      define_method severity do |message, &block|
        log severity, message, &block
      end
    end
  end
end
