module Slogger
  #
  # A delegate class to make possible to use Slogger in application which by
  # default use standard Ruby Logger. It just exposes the same API of standard
  # Ruby Logger class.
  #
  class CommonLogger < Base
    
    #
    # A bridge between standard Logger and Syslog
    #
    SEVERITIES = {
      :unknow  => :alert,
      :fatal   => :err,
      :error   => :warning,
      :warning => :notice,
      :info    => :info,
      :debug   => :debug
    }
    
    FACILITIES = ::Slogger::Logger::FACILITIES
    
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
      super app_name, severity, facility, self.class
      
      @syslogger = ::Slogger::Logger.new app_name, SEVERITIES[severity], facility
    end

    SEVERITIES.each_key do |severity|
      define_method severity do |message, &block|
        @syslogger.send SEVERITIES[severity], "StLg - #{message}", &block
      end
    end
  end
end
