require 'spec_helper.rb'

describe SimpleModel::Base do
  # We need a clean class for each spec

  around(:each) do |example|
    class BaseTest < SimpleModel::Base; end

    example.run

    Object.send(:remove_const,:BaseTest) if defined?(:BaseTest)
  end


  context 'action methods' do
    describe '#save' do
      it "should perform the supplied methods" do
        BaseTest.save :test
        BaseTest.has_attribute :foo
        BaseTest.send(:define_method, :test) do
          self.foo = "test"
          return true
        end

        base_test = BaseTest.new()

        base_test.save
        base_test.foo.should eql("test")
      end

      it "should be false if validation fails" do
        BaseTest.save :test
        BaseTest.has_attribute :foo
        BaseTest.validates :foo, :presence => true
        BaseTest.send(:define_method, :test) do
          return true
        end


        base_test = BaseTest.new()
        expect(base_test).to_not be_valid
        expect(base_test.save).to eql(false)
      end
    end

    describe '#save!' do
      it "should perform the supplied methods" do
        BaseTest.save :test
        BaseTest.has_attribute :foo
        BaseTest.send(:define_method, :test) do
          self.foo = "test"
          return true
        end

        base_test = BaseTest.new()

        base_test.save!
        base_test.foo.should eql("test")
      end

      it "should be false if validation fails" do
        BaseTest.save :test
        BaseTest.has_attribute :foo
        BaseTest.validates :foo, :presence => true
        BaseTest.send(:define_method, :test) do
          return true
        end


        base_test = BaseTest.new()
        expect(base_test).to_not be_valid
        expect{base_test.save!}.to raise_error(SimpleModel::ValidationError)
      end
    end

    describe '#destroy' do
      it "should not preform validation by default" do
        BaseTest.destroy :test
        BaseTest.has_attribute :foo
        BaseTest.validates :foo, :presence => true
        BaseTest.send(:define_method, :test) do
          return true
        end

        base_test = BaseTest.new()
        expect(base_test.destroy).to eql(true)
      end
    end
  end


  context 'Callbacks' do
    before(:each) do
      class BaseTest < SimpleModel::Base
        save :my_save_method
        before_validation :set_foo
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
    end

    let(:base_test) { BaseTest.new() }

    it "should implement ActiveModel::Validations::Callbacks" do
      base_test.valid?

      expect(base_test.foo).to eql('foo')
      expect(base_test.bar).to eql('bar')
    end

    it "should implement ActiveModel::Callbacks" do
      base_test.save

      expect(base_test.foo).to eql('foo')
      expect(base_test.bar).to eql('bar')
    end
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
    it "should merge defined attributes when class are inherited" do
      NewTestStuff.attribute_defined?(:bar).blank?.should eql(false)
      NewTestStuff.attribute_defined?(:foo).blank?.should eql(false)
    end
    it "should merge defined attributes when class are inherited" do
      TestStuff.new.respond_to?(:bar_will_change!).should eql(true)
      t = OtherStuff.new
      t.bar = [1,2,4]
      NewTestStuff.new.respond_to?(:bar_will_change!).should eql(true)
      NewTestStuff.new.respond_to?(:foo_will_change!).should eql(true)
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
end
