require 'spec_helper.rb'

describe SimpleModel::Attributes do

  # We need a clean class for each spec
  around(:each) do |example|
    class AttributesTest
      include SimpleModel::Attributes
    end

    example.run

    Object.send(:remove_const,:AttributesTest) if defined?(:AttributesTest)
  end

  context "class methods" do

    describe '#config' do
      it { expect(AttributesTest.config).to be_a(SimpleModel::Config) }
    end

    describe '#create_attribute_methods' do
      context "no options" do
        before(:each) do
          AttributesTest.create_attribute_methods([:has_foo],{})
        end

        let(:attributes_test) { AttributesTest.new() }

        it {expect(attributes_test).to respond_to(:has_foo)}
        it {expect(attributes_test).to respond_to(:has_foo=)}
        it {expect(attributes_test).to respond_to(:has_foo?)}
        it "should set the value" do
          expect(attributes_test.has_foo = "test").to eql("test")
        end

        it "should get the value" do
          attributes_test.has_foo = "test"
          expect(attributes_test.has_foo).to eql("test")
        end

        it "should get? boolean value" do
          expect(attributes_test).to_not be_has_foo
          attributes_test.has_foo = "test"
          expect(attributes_test).to be_has_foo
        end
      end

      context "options set" do

        context "with default" do

          context "with initialize == true" do
            before(:each) do
              AttributesTest.create_attribute_methods([:with_default], {:default => "foo", :initialize => true})
            end

            let(:attributes_test) { AttributesTest.new() }

            it "should work" do
              expect(attributes_test.attributes[:with_default]).to eql('foo')
            end

            context 'should override config setting' do
              it "should still work" do
                AttributesTest.config.initialize_defaults = false
                expect(attributes_test.attributes.key?(:with_default)).to eql(true)
              end

              it {expect(attributes_test.with_default).to eql('foo')}
            end

          end

          context "with initialize == false" do
            before(:each) do
              AttributesTest.create_attribute_methods([:with_default_no_init], {:default => "foo", :initialize => false})
            end

            let(:attributes_test) { AttributesTest.new() }

            it { expect(attributes_test.attributes).to_not have_key(:with_default_no_init) }

            it "should set on get" do
              expect(attributes_test.with_default_no_init).to eql('foo')
            end

            context 'config.initialize_defaults? == false' do
              
              it "should override config setting" do
                AttributesTest.config.initialize_defaults = true
                expect(attributes_test.attributes.key?(:with_default)).to eql(false)
              end

            end
          end

          context "set to a symbol for a method" do
            before(:each) do
              AttributesTest.send(:define_method, :default_method) do
                Date.today
              end

              AttributesTest.create_attribute_methods([:with_default_method], {:default => :default_method})
            end
            let(:attributes_test) { AttributesTest.new() }

            it { expect(attributes_test.with_default_method).to eql(Date.today) }
          end

          context "set to a non-method symbol" do
            before(:each) do
              AttributesTest.create_attribute_methods([:with_default_sym], {:default => :_foo})
            end

            let(:attributes_test) { AttributesTest.new() }

            it { expect(attributes_test.with_default_sym).to eql(:_foo) }
          end
        end

        context "with on_set" do
          before(:each) do
            AttributesTest.create_attribute_methods([:with_on_set], {:on_set => lambda {|obj,val| val.to_i } })
          end

          let(:attributes_test) { AttributesTest.new(:with_on_set => "1") }

          it {expect(attributes_test.with_on_set).to eql(1)}
        end

        context "with allow_blank == false" do
          before(:each) do
            AttributesTest.create_attribute_methods([:prevent_blank], {:allow_blank =>  false})
          end

          let(:attributes_test) { AttributesTest.new(:prevent_blank => "") }

          it "should not initialize" do
            expect(attributes_test.attributes).to_not have_key(:prevent_blank)
          end

          it "should allow setting with non-blank value" do
            attributes_test.prevent_blank = "not blank"
            expect(attributes_test.prevent_blank).to eql("not blank")
            attributes_test.prevent_blank = nil
            expect(attributes_test.prevent_blank).to eql("not blank")
            attributes_test.prevent_blank = 1
            expect(attributes_test.prevent_blank).to eql(1)
          end
        end

        context "with allow_blank == false and boolean == true" do
          before(:each) do
            AttributesTest.create_attribute_methods([:allow_false_boolean], {:allow_blank => false, :boolean => true})
          end
          let(:attributes_test) { AttributesTest.new(:allow_false_boolean => "") }

          it "should not initialize" do
            expect(attributes_test.attributes).to_not have_key(:allow_false_boolean)
          end

          it "should allow setting with non-blank value" do
            attributes_test.allow_false_boolean = 1
            expect(attributes_test.allow_false_boolean).to eql(1)
            attributes_test.allow_false_boolean = nil
            expect(attributes_test.allow_false_boolean).to eql(1)
            attributes_test.allow_false_boolean = false
            expect(attributes_test.allow_false_boolean).to eql(false)
          end
        end

        context "with :if" do
          context "set to a proc" do
            before(:each) do
              AttributesTest.has_date :if_proc, :if => lambda {|obj,val| !val.blank?}
            end

            it {expect(AttributesTest.new(:if_proc => nil)).to_not be_initialized(:if_proc)}

            it {expect(AttributesTest.new(:if_proc => "2014-05-01")).to be_initialized(:if_proc)}
          end

          context "set to a :blank" do
            before(:each) do
              AttributesTest.has_attribute :if_blank, :if => :blank
            end
            it "init" do
              init = AttributesTest.new(:if_blank => "")
              expect(init).to be_initialized(:if_blank)

            end
            it {expect(AttributesTest.new(:if_blank => nil)).to be_initialized(:if_blank)}
            it {expect(AttributesTest.new(:if_blank => "foo")).to_not be_initialized(:if_blank)}

          end

          context "set to a symbol" do
            before(:each) do
              AttributesTest.has_attribute :if_attr_1, :if => :if_true
              AttributesTest.has_attribute :if_attr_2, :if => :if_false

              AttributesTest.send :define_method, :if_true do
                true
              end

              AttributesTest.send :define_method, :if_false do
                false
              end
            end

            let(:attributes_test) { AttributesTest.new(:if_attr_1 => "test", :if_attr_2 => "test" ) }
            it {expect(attributes_test).to be_initialized(:if_attr_1)}
            it {expect(attributes_test).to_not be_initialized(:if_attr_2)}
          end
        end

        context "with :unless" do
          context "set to a proc" do
            before(:each) do
              AttributesTest.has_date :unless_proc, :unless => lambda {|obj,val| val.blank?}
            end

            it {expect(AttributesTest.new(:unless_proc => nil)).to_not be_initialized(:unless_proc)}

            it {expect(AttributesTest.new(:unless_proc => "2014-05-01")).to be_initialized(:unless_proc)}
          end

          context "set to a :blank" do
            before(:each) do
              AttributesTest.has_attribute :unless_blank, :unless => :blank
            end

            it {expect(AttributesTest.new(:unless_blank => "")).to_not be_initialized(:unless_blank)}
            it {expect(AttributesTest.new(:unless_blank => nil)).to_not be_initialized(:unless_blank)}
            it {expect(AttributesTest.new(:unless_blank => "foo")).to be_initialized(:unless_blank)}

          end

          context "set to a symbol" do
            before(:each) do
              AttributesTest.has_attribute :unless_attr_1, :unless => :unless_true
              AttributesTest.has_attribute :unless_attr_2, :unless => :unless_false

              AttributesTest.send :define_method, :unless_true do
                true
              end

              AttributesTest.send :define_method, :unless_false do
                false
              end
            end

            let(:attributes_test) { AttributesTest.new(:unless_attr_1 => "test", :unless_attr_2 => "test" ) }
            it {expect(attributes_test).to_not be_initialized(:unless_attr_1)}
            it {expect(attributes_test).to be_initialized(:unless_attr_2)}
          end
        end
      end # end with options
    end # end #create_attribute_methods

    describe '#has_attribute' do
      it {expect(AttributesTest).to respond_to(:has_attribute)}

      before(:each) do
        AttributesTest.has_attribute(:test_attr)
      end

      let(:attributes_test) { AttributesTest.new() }

      it {expect(attributes_test).to respond_to(:test_attr)}

    end

    describe '#has_boolean' do
      it {expect(AttributesTest).to respond_to(:has_boolean)}

      before(:each) do
        AttributesTest.has_boolean(:test_bool)
      end
      let(:attributes_test) { AttributesTest.new() }

      it {expect(attributes_test).to respond_to(:test_bool)}

      it "should cast to a boolean" do
        attributes_test.test_bool = "false"
        expect(attributes_test.test_bool).to eql(false)

        attributes_test.test_bool = "true"
        expect(attributes_test.test_bool).to eql(true)
      end
    end

    describe '#has_date' do
      it {expect(AttributesTest).to respond_to(:has_date)}

      before(:each) do
        AttributesTest.has_date(:test_date)
      end

      let(:attributes_test) { AttributesTest.new() }

      it {expect(attributes_test).to respond_to(:test_date)}

      it "should cast to a date" do
        attributes_test.test_date = "2014-12-22"
        expect(attributes_test.test_date).to be_a(Date)
      end
    end

    describe '#has_decimal' do
      it {expect(AttributesTest).to respond_to(:has_decimal)}

      before(:each) do
        AttributesTest.has_decimal(:test_deci)
      end

      let(:attributes_test) { AttributesTest.new() }

      it {expect(attributes_test).to respond_to(:test_deci)}

      it "should cast to a decimal" do
        attributes_test.test_deci = "1.0"
        expect(attributes_test.test_deci).to be_a(BigDecimal)
      end
    end

    describe '#has_float' do
      it {expect(AttributesTest).to respond_to(:has_float)}

      before(:each) do
        AttributesTest.has_float(:test_float)
      end

      let(:attributes_test) { AttributesTest.new() }

      it {expect(attributes_test).to respond_to(:test_float)}

      it "should cast to a float" do
        attributes_test.test_float = "1.0"
        expect(attributes_test.test_float).to be_a(Float)
      end
    end

    describe '#has_int' do
      it {expect(AttributesTest).to respond_to(:has_int)}

      before(:each) do
        AttributesTest.has_int(:test_int)
      end

      let(:attributes_test) { AttributesTest.new() }

      it {expect(attributes_test).to respond_to(:test_int)}

      it "should cast to a float" do
        attributes_test.test_int = "1"
        expect(attributes_test.test_int).to be_a(Fixnum)
      end
    end

    describe '#has_time' do
      it {expect(AttributesTest).to respond_to(:has_time)}

      before(:each) do
        AttributesTest.has_time(:test_time)
      end

      let(:attributes_test) { AttributesTest.new() }

      it {expect(attributes_test).to respond_to(:test_time)}

      it "should cast to a date" do
        attributes_test.test_time = "2014-12-22"
        expect(attributes_test.test_time).to be_a(Time)
      end
    end

    describe '#alias_attribute' do
      before(:each) do
        AttributesTest.has_attribute :base_foo
        AttributesTest.alias_attribute :alias_foo, :base_foo
      end

      context "attribute is not defined" do
        it { expect {AttributesTest.alias_attribute :alias_foo, :nope}.to raise_error(SimpleModel::UndefinedAttribute) }
      end

      it "should work" do
        test_alias = AttributesTest.new(:alias_foo => "foo")
        expect(test_alias.alias_foo).to eql("foo")
        expect(test_alias.base_foo).to eql("foo")
      end
    end

  end # end class methods



  context "initializing" do

    before(:each) do
      AttributesTest.has_attributes :test1,:test2
    end

    let(:init_test) { AttributesTest.new(:test1 => '1', :test2 => '2') }


    it { expect(init_test.test1).to eql('1') }
    it { expect(init_test.test2).to eql('2') }

    describe '#attributes' do
      it { expect(init_test).to respond_to(:attributes) }
      it { expect(init_test.attributes).to be_a(HashWithIndifferentAccess)}
    end



    describe '#before_initialize' do

      context "before_initialize is not a Proc" do
        it { expect {AttributesTest.before_initialize = "bad stuff"}.to raise_error }
      end

      before(:each) do
        # Do not initialize blank attributes
        AttributesTest.before_initialize = lambda {|obj,attrs| attrs.select{|k,v| !v.blank?}}
        AttributesTest.has_attribute :before_init
      end

      it "should work" do
        expect(AttributesTest.new(:before_init => "")).to_not be_initialized(:before_init)
        expect(AttributesTest.new(:before_init => "t")).to be_initialized(:before_init)
      end

    end

    describe '#after_initialize' do

      context "before_initialize is not a Proc" do
        it { expect {AttributesTest.after_initialize = "bad stuff"}.to raise_error }
      end

      before(:each) do
        # Do not initialize blank attributes
        AttributesTest.after_initialize = lambda { |obj| obj.after_init = "test" if obj.after_init.blank?}
        AttributesTest.has_attribute :after_init
      end

      it "should work" do
        expect(AttributesTest.new(:after_init => "").after_init).to eql("test")
      end

    end

    describe '#new_with_store'do
      it "should work" do
        my_store = {:test1 => 1,:test2 => 2}
        nw = AttributesTest.new_with_store(my_store)
        expect(AttributesTest.new_with_store(my_store).attributes.object_id).to eql(my_store.object_id)
      end
    end

    context "defaults" do
      before(:each) do
        AttributesTest.config.initialize_defaults = true
        AttributesTest.has_attribute :has_def, :default => "Test"
        AttributesTest.has_attribute :has_other, :default => "Other"
        AttributesTest.has_attribute :has_derived, :default => :default_derived

        class AttributesTest
          def default_derived
            val = "Derived" if has_def == "Test"
          end
        end
      end

      let(:defaults_test) { AttributesTest.new(:has_other => 'Foo') }

      it { expect(defaults_test.initialized?(:has_def)).to eql(true)}
      it { expect(defaults_test.has_def).to eql("Test")}

      it { expect(defaults_test.initialized?(:has_other)).to eql(true)}
      it { expect(defaults_test.has_other).to eql("Foo")}

      it { expect(defaults_test.initialized?(:has_derived)).to eql(true)}
      it { expect(defaults_test.has_derived).to eql("Derived")}
    end
  end

  context "inheritance" do
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

    it "should merge defined attributes when class are inherited" do
      expect(NewerBase).to be_attribute_defined(:bar)
      newer_base = NewerBase.new
      expect(newer_base).to respond_to(:bar_will_change!)
    end

    it "should set defaults that were not initialized should work from parent class" do
      newer_base = NewerBase.new
      expect(newer_base.some).to eql(newer_base.send(:fetch_date))
      expect(newer_base.thing).to eql(newer_base.send(:fetch_date))
    end

    it "should allow redefining methods in child classes" do
      newer_base = NewerBase.new
      newer_base.str = '1'
      expect(newer_base.str).to eql(1)
    end

    it "should set attribute from alias" do
      expect(MyBase.new(:other => true)).to be_bar
      expect(NewerBase.new(:other => true)).to be_bar
    end

    it "should properly alias attributes from parent class" do
      newer_base =  NewestBase.new(:some_amount => 1.0)
      expect(newer_base.other_amount).to eql(1.0.to_d)
      expect(newer_base.amount).to eql(1.0.to_d)
    end
  end
end
