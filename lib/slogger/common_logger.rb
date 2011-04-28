module Slogger
  #
  # An adapter to make possible to use Slogger in application which by default
  # use standard Ruby Logger.
  #
  module CommonLogger
    
    #
    # A bridge between standard Logger and Syslog
    #
    SEVERITY = {
      :debug   => :debug,
      :info    => :info,
      :warning => :notice,
      :error   => :warning
      :fatal   => :err,
      :unknow  => :alert
    }
  end

  SEVERITY.each_key do |severity|
    define_method severity do |message, &block|
      send SEVERITY[severity], message, &block
    end
  end
end
