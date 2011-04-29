module Slogger
  #
  # A delegate class to make possible to use Slogger in application which by
  # default use standard Ruby Logger. It just exposes the same API of standard
  # Ruby Logger class.
  #
  class CommonLogger < Base
    
    SEVERITIES = {
      :unknow  => Syslog::LOG_EMERG,
      :fatal   => Syslog::LOG_ALERT,
      :error   => Syslog::LOG_ERR,
      :warning => Syslog::LOG_WARNING,
      :info    => Syslog::LOG_INFO,
      :debug   => Syslog::LOG_DEBUG
    }

    #
    # Bridge between standard Ruby Logger and Syslog
    #
    LOGGER_TO_SYSLOG_SEVERITIES = {
      :unknow  => :emerg,
      :fatal   => :alert,
      :error   => :err,
      :warning => :warning,
      :info    => :info,
      :debug   => :debug
    }

    #
    # Just a little sugar
    #
    FACILITIES = ::Slogger::Base::SYSLOG_FACILITIES
    
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
      super app_name, severity, facility, SEVERITIES
    end

    SEVERITIES.each_key do |severity|
      define_method severity do |message, &block|
        log LOGGER_TO_SYSLOG_SEVERITIES[severity], message, &block
      end
    end
  end
end
