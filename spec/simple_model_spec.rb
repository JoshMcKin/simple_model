require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe SimpleModel do
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
end

describe SimpleModel::Errors do
  it 'Should add a error setter' do
    class TestError
      include SimpleModel::Errors
      attr_accessor :test_attr
    end
    a = TestError.new(self)
    a.errors.add(:test_attr, "test")
    a.errors?.should be_true

    #a.test.should be_false
  end
end