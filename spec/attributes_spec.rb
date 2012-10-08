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

end
describe SimpleModel::Attributes, 'has_attribute' do
  before(:each) do
    class TestDefault
      include SimpleModel::Attributes
      has_attribute :foo, :default => "foo"
      has_attribute :bar, :default => :default_value
      has_attribute :fab , :default => :some_symbol
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
describe SimpleModel::Attributes, 'has_attributes' do
  before(:all) do
    class TestBoolean
      include SimpleModel::Attributes
      has_attributes :my_array, :default => []
    end
  end

  it "should allow default value to be an empty array" do
    test = TestBoolean.new
    test.my_array.should eql([])
  end

end

