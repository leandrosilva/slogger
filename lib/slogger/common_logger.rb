require 'logger'

module Slogger
  #
  # It just exposes Ruby's Syslog with the same API of Ruby's standard Logger class. So
  # you can use it in a Rails application, for instance.
  #
  # For example, add the snippet below to the config/environments/developement.rb of an
  # Rails application:
  #
  # config.log_level = :info
  # config.logger = Slogger::CommonLogger.new "rappils", config.log_level, :local0
  #
  # That's all. The Rails application will log everything to the standard syslog.
  #
  class CommonLogger < Base

    SEVERITIES = {
      :emerg   => Syslog::LOG_EMERG,
      :alert   => Syslog::LOG_ALERT,
      :err     => Syslog::LOG_ERR,
      :info    => Syslog::LOG_INFO,
      :debug   => Syslog::LOG_DEBUG,
      :warn    => Syslog::LOG_WARNING,
    }

    #
    # Bridge between standard Ruby Logger and Syslog
    #
    BRIDGE_SEVERITIES = {
      :unknow  => :emerg,
      :fatal   => :alert,
      :error   => :err,
      :warn    => :warning,
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
    #                 :error, :warn, :info, or :debug. It can be changed at anytime.
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

    def log(severity, message = nil, &block)
      if block_given? and message != nil
        super(severity, message, &block)
      else
        super(severity, (message || (block_given? && block.call) || @app_name), &nil)
      end
    end

    def add(severity, message = nil, progname = nil, &block)
      (BRIDGE_SEVERITIES.keys - [:unknow]).each do |key|
        if ::Logger.const_get(key.to_s.upcase) == severity
          return log(BRIDGE_SEVERITIES[key], message, &block)
        end
      end

      log(BRIDGE_SEVERITIES[:unkown], message, &block)
    end

    BRIDGE_SEVERITIES.each_key do |severity|
      define_method severity do |message = nil, &block|
        log BRIDGE_SEVERITIES[severity], message, &block
      end

      define_method "#{severity}?" do
        SEVERITIES[BRIDGE_SEVERITIES[severity]] <= SEVERITIES[BRIDGE_SEVERITIES[@severity]]
      end
    end
  end
end
