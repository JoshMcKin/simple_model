require 'spec_helper.rb'

describe SimpleModel do 
  context 'action methods' do
    describe "save" do  
      it "should perform the supplied methods" do
        class TestStuff < SimpleModel::Base
          save :test  
          attr_accessor :foo
        
          def test
            self.foo = "test"
            return true
          end
        end
      
        t = TestStuff.new
        t.save
        t.foo.should eql("test")
      end
      
      it "should be false if validation fails" do
        class TestStuff < SimpleModel::Base
          save :test
          has_decimal :price
          validates_inclusion_of :price, :in => 10..25
          validates :price, :presence => true
          
        
          def test
            true
          end
        end
      
        t = TestStuff.new
        t.save.should be_false
      end
    end
  
    describe "destroy" do
      it "should not preform validation by default" do
        class TestStuff < SimpleModel::Base
          destroy :test
          attr_accessor :foo
          validate :foo, :presence => true
          def test
            return true
          end
        end
      
        t = TestStuff.new
        t.destroy.should be_true
      end
    end
    context "action methods that end with '!'" do
      it 'should raise exception if validation fails' do
        class TestStuff < SimpleModel::Base
          save :my_save_method
          has_attributes :foo
      
          def my_save_method
            false
          end
        end
    
        t = TestStuff.new
        lambda {t.save!}.should raise_error(SimpleModel::ActionError)
      end
      it 'should raise exception if validation fails' do
        class TestStuff < SimpleModel::Base
          save :my_save_method
          has_attributes :foo
          validate :validates_bar
      
          def my_save_method
            self.errors.blank?
          end
      
          def validates_bar
            self.errors.add(:foo, "bar")
          end
        end
    
        t = TestStuff.new
        lambda {t.save!}.should raise_error(SimpleModel::ValidationError)
      end
      
    end
  end
  
  
  it 'Should add a boolean setter' do
    class TestStuff < SimpleModel::Base
      has_booleans :test_boolean
    end
    TestStuff.new.methods.include?(:test_boolean).should be_true
    #a.test.should be_false
  end
  it 'Should add a boolean setter' do
    class TestStuff < SimpleModel::Base
      has_booleans :test_boolean
    end
    t =  TestStuff.new
    t.methods.include?(:test_boolean).should be_true
    t.test_boolean = true
    t.test_boolean.should be_true
    #a.test.should be_false
  end
  it 'Should add a error setter' do

    class TestStuff < SimpleModel::Base
      has_attributes :test_attr
    end
    a = TestStuff.new

    a.errors.add(:test_attr, "test")
    a.errors?.should be_true
  end
  
  it 'Should include validation callbacks' do
    class TestStuff < SimpleModel::Base
    end
    TestStuff.respond_to?(:before_validation).should be_true
    TestStuff.respond_to?(:after_save).should be_true
    
  end
  
  it 'Should include peform validation callbacks' do
    class TestStuff < SimpleModel::Base
      before_validation :set_foo   
      after_validation :set_bar
      attr_accessor :foo,:bar
      validates :foo, :presence => true
     
         
      private
      def set_foo
        self.foo = "foo"
      end
      
      def set_bar
        self.bar = "bar"
      end
    end
    
    t = TestStuff.new
    t.valid?
    t.foo.should eql('foo') 
    t.bar.should eql('bar')
  end
  
  it "should run save and validation callbacks on save" do
    class TestStuff < SimpleModel::Base
      save :my_save_method
      before_save :set_foo   
      after_validation :set_bar
      attr_accessor :foo,:bar
      validates :foo, :presence => true
     
      
      private
      
      def my_save_method
        true
      end
      
      def set_foo
        self.foo = "foo"
      end
      
      def set_bar
        self.bar = "bar"
      end
    end
    
    t = TestStuff.new
    t.save
    t.foo.should eql('foo') 
    t.bar.should eql('bar')
  end
  
  it 'Should implement ActiveModel::Dirty' do
    class TestStuff < SimpleModel::Base
      save :my_save_method
      has_attributes :foo,:bar, :default => "def"
      has_boolean :boo,:bad, :default => true
      def my_save_method
        true
      end
    end
    
    t = TestStuff.new
    t.foo = "bar"
    t.foo_changed?.should be_true
    t.respond_to?(:foo_will_change!).should be_true
    t.respond_to?(:boo_will_change!).should be_true
    t.foo_change.should eql(["def","bar"])
    t.changed?.should be_true
    t.save
    t.changed?.should be_false
  end 
  
  context "regression tests" do
    before(:each) do
      class TestStuff < SimpleModel::Base
        has_attribute :bar
        validates_presence_of :bar
      end
      
      class NewTestStuff < TestStuff
        has_boolean :foo
      end
      
      class OtherStuff < NewTestStuff
        has_attribute :other
        validates_numericality_of :other
      end
           
    end
    it "should merge defined attributes when class are inhereted" do
      NewTestStuff.attribute_defined?(:bar).blank?.should be_false
      NewTestStuff.attribute_defined?(:foo).blank?.should be_false
    end
    it "should merge defined attributes when class are inhereted" do
      TestStuff.new.respond_to?(:bar_will_change!).should be_true
      t = OtherStuff.new
      t.bar = [1,2,4]
      NewTestStuff.new.respond_to?(:bar_will_change!).should be_true
      NewTestStuff.new.respond_to?(:foo_will_change!).should be_true
    end
    
    it "should not throw exception method missing" do
      o = OtherStuff.new
      lambda { o.valid? }.should_not raise_error
    end
    
    after(:each) do
      [:OtherStuff,:NewTestStuff].each do |con|
        Object.send(:remove_const,con)
      end
    end
  end
  
  after(:each) do
    Object.send(:remove_const,:TestStuff)
  end
end
