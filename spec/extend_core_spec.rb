
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
describe SimpleModel::ExtendCore, 'Float.rb' do
  before(:all) do
    include SimpleModel::ExtendCore
  end

  describe SimpleModel::ExtendCore, 'round' do
    it "should return float rounded to specified precision" do
      0.5122.round_to.should eql(1.0)
      0.3333.round_to(1).should eql(0.3)
      0.33335.round_to(2).should eql(0.33)
      0.33335.round_to(4).should eql(0.3334)
    end
  end

  describe SimpleModel::ExtendCore, 'to_currency_s' do
    it "should return a string" do
      0.333.to_currency_s.class.should eql(String)
    end
#    it "should prefix string with currency symbol" do
#      5.12.to_currency_s.include?("$").should be_true
#    end
#    it "should padd with zeros for cents" do
#      5.0.to_currency_s.should eql("$5.00")
#    end
#    it "should round string to nearest tenth" do
#      0.333.to_currency_s.should eql("$0.33")
#    end
#    it "should add commas to long numbers" do
#      500000000000.0.to_currency_s.should eql("$500,000,000,000.00")
#      50000000000.0.to_currency_s.should eql("$50,000,000,000.00")
#      5000000000.0.to_currency_s.should eql("$5,000,000,000.00")
#    end
  end

end


describe SimpleModel::ExtendCore, 'String.rb' do
  before(:all) do
    include SimpleModel::ExtendCore
  end
  describe SimpleModel::ExtendCore, 'safe_datetime_string' do
    it "should set US formated datetime string to international" do
      "12/31/2010".safe_datetime_string.should eql("2010-12-31")
      "12/31/2010T23:31:59".safe_datetime_string.should eql("2010-12-31T23:31:59")
      "12/31/2010 23:31:59".safe_datetime_string.should eql("2010-12-31 23:31:59")

    end
  end
  
  describe SimpleModel::ExtendCore, 'to_b' do
    it "should return a Boolean" do
      "1".to_b.class.should eql(TrueClass)
      "".to_b.class.should eql(FalseClass)
    end

    it "should return true if string is '1' or 't' or 'true'"do
      ['1','t','true'].each do |s|
        s.to_b.should be_true
      end
    end  
  end

  describe SimpleModel::ExtendCore, 'to_date' do
    it "return a Date object" do
      "12/31/2010".to_date.class.should eql(Date)
    end
  end
  describe SimpleModel::ExtendCore, 'to_date' do
    it "return a Time object" do
      "12/31/2010".to_time.class.should eql(Time)
    end
  end
  describe SimpleModel::ExtendCore, 'to_f' do
    it "return a Foat from a string that may contain non-numeric values" do
      "$5,000.006".to_f.should eql(5000.006)
    end
  end
  describe SimpleModel::ExtendCore, 'to_currency' do
    it "return a BigDecimal from a string that may contain non-numeric values" do
      "$5,000.006".to_currency.should eql(BigDecimal("5000.01"))
    end
  end

  describe SimpleModel::ExtendCore, 'parse_name' do
    it "return return hash with name elements properly keyed" do
      hash = "Doe, John C.".parse_name
      hash[:first_name].should eql("John")
      hash[:last_name].should eql("Doe")

      hash = "John Doe".parse_name
      hash[:first_name].should eql("John")
      hash[:last_name].should eql("Doe")

      hash = "Mr. John C. Doe Jr".parse_name
      hash[:first_name].should eql("John")
      hash[:last_name].should eql("Doe")

    end
  end
end
