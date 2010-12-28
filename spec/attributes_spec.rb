require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe SimpleModel::Attributes do
  before(:all) do
    class TestInit
      include SimpleModel::Attributes
      has_attributes :test1,:test2
    end
    @init = TestInit.new(:test1 => "1", :test2 => '2')
  end

  it "should set provided attributes on initialize" do
    
    @init.test1.should eql("1")
    @init.test2.should eql("2")
  end

  it "should include set attributes in attributes hash" do
    @init.attributes.class.should eql(Hash)
    @init.attributes[:test1].should eql("1")
    @init.attributes[:test2].should eql("2")
  end

end
describe SimpleModel::Attributes, 'define_reader_with_options' do
  before(:all) do
    class TestDefault
      include SimpleModel::Attributes
      attr_accessor :test
      define_reader_with_options :test, :default => "test"
    end
  end

  it "should define setter method with default value" do
    default = TestDefault.new
    default.test.should eql("test")
  end
  it "should not intefer with setting" do
    default = TestDefault.new
    default.test = "New"
    default.test.should eql("New")
  end

end
describe SimpleModel::Attributes, 'has_booleans' do
  before(:all) do
    class TestBoolean
      include SimpleModel::Attributes
      has_booleans :test
    end
  end

  it "should add setter=, getter and getter? methods" do
    methods = TestBoolean.new.methods
    union = methods | [:test, :test=, :test?]
    union.should eql(methods)
  end

end
