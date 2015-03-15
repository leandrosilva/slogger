require File.join(File.dirname(__FILE__), "..", "/spec_helper")

describe Slogger::CommonLogger do
  subject { Slogger::CommonLogger.new "test_app", :debug, :local0 }

  describe "#formatter" do
    it "should respond to #formatter" do
      subject.should respond_to(:formatter)
    end
  end

  describe "valid state" do
    it "should have an app_name attribute" do
      subject.app_name.should == "test_app"
    end

    it "should have a severity attribute" do
      subject.severity.should == :debug
    end

    it "should have a facility attribute" do
      subject.facility.should == :local0
    end
  end

  describe "#level" do
    mappings = {
      :debug => Logger::DEBUG,
      :info => Logger::INFO,
      :warn => Logger::WARN,
      :error => Logger::ERROR,
      :fatal => Logger::FATAL
    }

    mappings.each_pair do |key, value|
      it "should map #{key.inspect} to #{value}" do
        logger = Slogger::CommonLogger.new "test_app", key, :local0
        logger.level.should == value
      end
    end
  end

  describe "invalid state" do
    it "should raise ArgumentError if doesn't have app_name" do
      lambda { Slogger::CommonLogger.new nil, :debug, :local0 }.should raise_error
    end

    it "should raise ArgumentError if doesn't have severity" do
      lambda { Slogger::CommonLogger.new "test_app", nil, :local0 }.should raise_error
    end

    it "should raise ArgumentError if doesn't have facility" do
      lambda { Slogger::CommonLogger.new "test_app", :debug, nil }.should raise_error
    end

    it "should raise ArgumentError if severity level is invalid" do
      lambda { Slogger::CommonLogger.new "test_app", :junk, :local0 }.should raise_error
    end

    it "should raise ArgumentError if facility is invalid" do
      lambda { Slogger::CommonLogger.new "test_app", :describe, :junk }.should raise_error
    end
  end

  describe "severity setup" do
    it "should be possible to change severity attribute" do
      subject.severity.should be :debug
      subject.severity = :warn
      subject.severity.should be :warn
      subject.severity = :info
      subject.severity.should be :info
    end

    it "should raise ArgumentError if try to change severity attribute to a invalid one" do
      lambda { subject.severity = :junk }.should raise_error
    end

    it "should still log after severity is set to warn" do
      subject.severity = :warn
      expect { subject.debug("Hello Logs!") }.not_to raise_error
    end
  end

  describe "logging" do
    describe "when is in WARN severity" do
      subject { Slogger::CommonLogger.new "test_app", :warn, :local0 }

      it { should respond_to(:add) }

      it "should log ERROR messsages with the add method" do
        Syslog.should_receive(:err).with('%s','ERROR message').and_return(Syslog)
        subject.add(::Logger::ERROR, 'ERROR message')
      end

      it "should log UNKNOW messages" do
        Syslog.should_receive(:emerg).with('%s',anything).and_return(Syslog)

        subject.unknow "UNKNOW message"
      end

      it "should log FATAL messages" do
        Syslog.should_receive(:alert).with('%s',anything).and_return(Syslog)

        subject.fatal "FATAL message"
      end

      it "should log ERROR messages" do
        Syslog.should_receive(:err).with('%s',anything).and_return(Syslog)

        subject.error "ERROR message"
      end

      it "should log WARN messsages with the add method to the WARNING severity" do
        Syslog.should_receive(:warning).with('%s','WARN message').and_return(Syslog)
        subject.add(::Logger::WARN, 'WARN message')
      end

      it "should log WARN messages to the WARNING severity" do
        Syslog.should_receive(:warning).with('%s',anything).and_return(Syslog)
        subject.warn "WARN message"
      end

      it "shouldn't log INFO messages" do
        Syslog.should_not_receive(:info).with('%s',anything).and_return(Syslog)

        subject.info "INFO message"
      end

      describe "but when severity is changed to INFO" do
        it "should log INFO messages" do
          subject.severity = :info

          Syslog.should_receive(:info).with('%s',anything).and_return(Syslog)

          subject.info "INFO message"
        end
      end
    end

    describe "when no message is passed to the log method" do
      it "should use the block to form the message" do
        subject.severity = :info

        messenger = mock('messenger')
        messenger.should_receive(:message).and_return('this is a message %s')
        Syslog.should_receive(:info).with('%s','this is a message logger').and_return(Syslog)
        subject.info { messenger.message % ('logger') }
      end
    end

    describe "when a block is passed to log method" do
      it "should add spent time to the message" do
        Syslog.should_receive(:info).with('%s',/\[time: [0-9.]+\] a block wrapped by log/)
        subject.info "a block wrapped by log" do
          sleep(1)
        end
      end
    end
  end

  describe "severity appliance checking" do
    it "should validate appliance for selected severity" do
      subject.debug?.should be_true
    end

    it "should validate appliance for less restrict severities" do
      subject.error?.should be_true
    end

    it "should invalidate appliance for more restrict severities" do
      subject.severity = :info
      subject.debug?.should be_false
    end
  end
end
