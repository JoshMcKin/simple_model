require 'spec_helper.rb'

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

  context '#before_initialize' do
    before(:all) do
      class TestInit
        include SimpleModel::Attributes
        # Do not initialize blank attributes
        self.before_initialize = lambda {|obj,attrs| attrs.select{|k,v| !v.blank?}}
        has_attribute :far
      end
    end

    it "should raise an exception if we try to set to something other than a Proc" do
      lambda {TestInit.before_initialize = "bad stuff"}.should raise_error
    end

    it "should run the supplied lambda" do
      t = TestInit.new(:far => "")
      t.initialized?(:far).should eql(false)
      t = TestInit.new(:far => "t")
      t.initialized?(:far).should eql(true)
    end

  end

  context '#after_initialize' do
    before(:all) do
      class TestInit
        include SimpleModel::Attributes
        # Do not initialize blank attributes
        self.after_initialize = lambda { |obj| obj.car = "test" if obj.car.blank?}
        has_attribute :car
      end
    end

    it "should raise an exception if we try to set to something other than a Proc" do
      lambda {TestInit.after_initialize = "bad stuff"}.should raise_error
    end

    it "should run the supplied lambda" do
      t = TestInit.new(:far => "")
      t.car.should eql("test")
    end

  end

  context '#new_with_store'do
    it "should use the provided object as the attribute store" do
      my_store = {:test1 => 1,:test2 => 2}
      nw = TestInit.new_with_store(my_store)
      nw.test1 = 3
      nw.test1.should eql(3)
      my_store[:test1].should eql(nw.test1)
    end
  end

  context "AVAILABLE_ATTRIBUTE_METHODS" do
    SimpleModel::Attributes::ClassMethods::AVAILABLE_ATTRIBUTE_METHODS.each do |m,options|
      it "should respond to #{m}" do
        TestInit.respond_to?(m).should eql(true)
      end
      it "should respond to alias #{options[:alias]}" do
        TestInit.respond_to?(options[:alias]).should eql(true)
      end
    end
  end

  context '#has_attribute' do
    before(:all) do
      class TestDefault
        include SimpleModel::Attributes
        has_attribute :foo, :default => "foo", :allow_blank => false
        has_attribute :bar, :default => :default_value
        has_attribute :fab, :default => :some_symbol
        has_attribute :hop, :default => :default_hop, :allow_blank => false
        has_attribute :tip, :default => "2", :initialize => false, :allow_blank => false
        has_attribute :nap
        has_attribute :my_array, :default => []
        def default_value
          "bar"
        end

        def default_hop
          "hop" if nap
        end
      end

    end

    before(:each) do
      @default = TestDefault.new
    end

    it "should define setter method" do
      @default.respond_to?(:foo=).should eql(true)
    end

    it "should define reader/getter method" do
      @default.respond_to?(:foo).should eql(true)
    end

    context ':initialize => false' do
      it "should not initialize with the default value" do
        @default.attributes[:tip].should be_nil
        @default.tip.should eql("2")
      end
      context "allow_blank => false"do
        it "should not initialize, but should set the value on get" do
          @default.attributes[:tip].should be_nil
          @default.tip.should eql("2")
        end
      end
    end

    it "should call the method it describe by the default value if it exists" do
      @default.attributes[:bar].should eql("bar")
    end

    it "should set the default to the supplied symbol, if the method does not exist" do
      @default.attributes[:fab].should eql(:some_symbol)
    end

    it "should allow default value to be an empty array" do
      @default.my_array.should eql([])
    end

    it "should create a boolean? method for each attribute" do
      @default.respond_to?(:foo?).should eql(true)
    end

    it "should return !blank?" do
      @default.my_array.should eql([]) # blank array
      @default.my_array?.should eql(false)
      @default.my_array << 1
      @default.my_array?.should eql(true)
    end

    it "should not allow blank if set" do
      @default.foo.should eql("foo")
      @default.foo = ""
      @default.foo.should eql("foo")
      @default.foo = "not blank"
      @default.foo.should eql("not blank")
    end

    it "should try for the default if its blank on get" do
      @default.hop.blank?.should eql(true)
      @default.nap = "yep"
      @default.hop.should eql("hop")
    end
  end

  context 'options with conditional' do
    before(:all) do
      class WithConditional
        include SimpleModel::Attributes
        has_date :my_date, :if => lambda {|obj,val| !val.blank?}
        has_date :my_other_date, :unless => :blank
      end
    end
    it "should not raise error" do
      new = WithConditional.new(:my_date => nil)
      new.initialized?(:my_date).should eql(false)
    end

    it "should call blank on val if :blank is supplied" do
      new = WithConditional.new(:my_other_date => nil)
      new.initialized?(:my_other_date).should eql(false)
    end
  end

  context "on get" do
    it "should perform on_get when set" do
      class OnGet
        include SimpleModel::Attributes
        has_attribute :foo, :on_get => lambda{|obj,attr| (attr.blank? ? obj.send(:foo_default) : attr)}

        def foo_default
          "test"
        end
      end

      new = OnGet.new
      new.foo.should eql("test")
      new.foo = "foo"
      new.foo.should eql("foo")
    end
  end

  context 'if supplied value can be cast' do
    before(:all) do
      class TestAlias
        include SimpleModel::Attributes
        has_attribute :foo, :default => "bar"
        alias_attribute(:bar,:foo)
      end
    end
    context '#alias_attribute' do
      it "should create alias for attribute" do
        t = TestAlias.new(:bar => "foo")
        t.bar.should eql("foo")
        t.foo.should eql('foo')
        t = TestAlias.new(:foo => "foo")
        t.bar.should eql("foo")
        t.foo.should eql('foo')
      end
    end
  end

  context "regression tests" do
    before(:all) do
      class MyBase
        include SimpleModel::Attributes
        has_boolean :bar
        has_attribute :str, :stuff
        has_currency :amount, :default => BigDecimal("0.0"), :initialize => false
        has_dates :some, :thing, :default => :fetch_date, :allow_blank => false, :initialize => false
        alias_attribute :other, :bar
        alias_attribute :other_amount, :amount

        def fetch_date
          Date.today
        end
      end

      class NewerBase < MyBase
        has_boolean :foo
        has_int :str
      end

      class NewestBase < NewerBase
        alias_attribute :some_amount, :other_amount
      end

    end
    it "should merge defined attributes when class are inherited" do
      NewerBase.attribute_defined?(:bar).should eql(true)
      n = NewerBase.new
      n.respond_to?(:bar_will_change!).should eql(true)
    end

    it "should set defaults that were not initialized should work from parent class" do
      n = NewerBase.new
      n.some.should eql(n.send(:fetch_date))
      n.thing.should eql(n.send(:fetch_date))
    end

    it "should allow redefining methods in child classes" do
      n = NewerBase.new
      n.str = '1'
      n.str.should eql(1)
    end

    it "should set attribute from alias" do
      MyBase.new(:other => true).bar?.should eql(true)
      NewerBase.new(:other => true).bar?.should eql(true)
    end

    it "should properly alias attributes from parent class" do
     nb =  NewestBase.new(:some_amount => 1.0)
     nb.other_amount.should eql(1.0.to_d)
     nb.amount.should eql(1.0.to_d)
    end
  end

  after(:all) do
    [:OnGet,:TestDefault,:TestInit,:MyBase,:NewerBase].each do |test_klass|
      Object.send(:remove_const,test_klass) if defined?(test_klass)
    end
  end
end
