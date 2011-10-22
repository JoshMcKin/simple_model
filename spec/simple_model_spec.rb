require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe SimpleModel do
  
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
  
  it "should run call backs on save" do
    class TestStuff < SimpleModel::Base
      save do
        puts "saved"
        true
      end
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
end

#describe SimpleModel::Errors do
#  it 'Should add a error setter' do
#    class TestError
#      include SimpleModel::Errors
#      attr_accessor :test_attr
#    end
#    a = TestError.new(self)
#    a.errors.add(:test_attr, "test")
#    a.errors?.should be_true
#
#    #a.test.should be_false
#  end
#end