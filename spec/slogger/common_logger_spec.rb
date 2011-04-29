require File.join(File.dirname(__FILE__), "..", "/spec_helper")

describe Slogger::CommonLogger do
  subject { Slogger::CommonLogger.new "test_app", :debug, :local0 }

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
      subject.severity = :warning
      subject.severity.should be :warning
      subject.severity = :info
      subject.severity.should be :info
    end
      
    it "should raise ArgumentError if try to change severity attribute to a invalid one" do
      lambda { subject.severity = :junk }.should raise_error
    end
  end
  
  describe "logging" do
    describe "when is in WARNING severity" do
      subject { Slogger::CommonLogger.new "test_app", :warning, :local0 }

      it "should log UNKNOW messages" do
        Syslog.should_receive(:emerg).with(anything).and_return(Syslog)

        subject.unknow "UNKNOW message"
      end

      it "should log FATAL messages" do
        Syslog.should_receive(:alert).with(anything).and_return(Syslog)

        subject.fatal "FATAL message"
      end
      
      it "should log ERROR messages" do
        Syslog.should_receive(:err).with(anything).and_return(Syslog)

        subject.error "ERROR message"
      end

      it "should log WARNING messages" do
        Syslog.should_receive(:warning).with(anything).and_return(Syslog)

        subject.warning "WARNING message"
      end
    
      it "shouldn't log INFO messages" do
        Syslog.should_not_receive(:info).with(anything).and_return(Syslog)

        subject.info "INFO message"
      end
      
      describe "but when severity is changed to INFO" do
        it "should log INFO messages" do
          subject.severity = :info
          
          Syslog.should_receive(:info).with(anything).and_return(Syslog)
          
          subject.info "INFO message"
        end
      end
    end

    describe "when a block is passed to log method" do
      it "should add spent time to the message" do
        subject.info "a block wrapped by log" do
          sleep(2)
        end
      end
    end
  end
end
