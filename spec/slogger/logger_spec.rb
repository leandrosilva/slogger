require File.join(File.dirname(__FILE__), "..", "/spec_helper")

describe Slogger::Logger do
  describe "valid state" do
    subject { Slogger::Logger.new "test_app", :debug, :local0 }

    its(:app_name) { should == "test_app" }
    its(:level) { should == :debug }
    its(:facility) { should == :local0 }
  end
  
  describe "invalid state" do
    it "should raise ArgumentError if doen't have app_name" do
      lambda { Slogger::Logger.new nil, :debug, :local0 }.should raise_error
    end

    it "should raise ArgumentError if doen't have level" do
      lambda { Slogger::Logger.new "test_app", nil, :local0 }.should raise_error
    end

    it "should raise ArgumentError if doen't have facility" do
      lambda { Slogger::Logger.new "test_app", :debug, nil }.should raise_error
    end
  end
  
  describe "when in warning level" do
    subject { Slogger::Logger.new "test_app", :warning, :local0 }

    it "should log WARNING messages" do
      Syslog.stub!(:warning).with(anything).and_return(Syslog)
      Syslog.should_receive(:warning).and_return(Syslog)

      subject.warning "WARNING message"
    end
    
    it "shouldn't log INFO messages" do
      Syslog.stub!(:info).with(anything).and_return(Syslog)
      Syslog.should_not_receive(:info).and_return(Syslog)

      subject.info "INFO message"
    end
  end
end
