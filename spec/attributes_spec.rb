require File.expand_path(File.dirname(__FILE__) + '/spec_helper.rb')

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
    @init.attributes.should be_kind_of(ActiveSupport::HashWithIndifferentAccess)
    @init.attributes[:test1].should eql("1")
    @init.attributes[:test2].should eql("2")
  end
  
  context "AVAILABLE_ATTRIBUTE_METHODS" do
    SimpleModel::Attributes::ClassMethods::AVAILABLE_ATTRIBUTE_METHODS.each do |m,options|
      it "should respond to #{m}" do
        TestInit.respond_to?(m).should be_true
      end
      it "should respond to alias #{options[:alias]}" do
        TestInit.respond_to?(options[:alias]).should be_true
      end
    end
  end

  context '#has_attribute' do
    before(:all) do
      class TestDefault
        include SimpleModel::Attributes
        has_attribute :foo, :default => "foo"
        has_attribute :bar, :default => :default_value
        has_attribute :fab , :default => :some_symbol
        has_attribute :my_array, :default => []
        def default_value
          "bar"
        end
      end
      @default = TestDefault.new
    end

    it "should define setter method" do
      @default.respond_to?(:foo=).should be_true
    end
  
    it "should define reader/getter method" do
      @default.respond_to?(:foo).should be_true
    end
  
    it "should initialize with the default value" do
      @default.attributes[:foo].should eql("foo")
    end
    it "should call the method it describe by the default value if it exists" do 
      @default.attributes[:bar].should eql("bar")
    end
    it "should set the defaul to the supplied symbol, if the method does not exist" do 
      @default.attributes[:fab].should eql(:some_symbol)
    end
    it "should allow default value to be an empty array" do
      @default.my_array.should eql([])
    end
    it "should create a boolean? method for each attribute" do
      @default.respond_to?(:foo?).should be_true
    end
  end
  
  context "on get" do
    it "should perform on_get when set" do
      class OnGet
        include SimpleModel::Attributes
        has_attribute :foo, :on_get => lambda{|attr| (attr.blank? ? "test" : attr)}
      end
      
      new = OnGet.new
      new.foo.should eql("test")
      new.foo = "foo"
      new.foo.should eql("foo")
    end
  end
  
  context 'if supplied value can be cast' do
    it "should throw an exception" do  
      class TestThrow
        include SimpleModel::Attributes
        has_booleans :boo
      end 
      
      lambda{TestThrow.new(:boo => [])}.should raise_error(SimpleModel::ArgumentError)
    end
        
  end
end