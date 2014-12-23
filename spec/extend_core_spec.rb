require 'spec_helper'
describe SimpleModel::ExtendCore, 'Float.rb' do
  before(:all) do
    include SimpleModel::ExtendCore
  end

  describe  '#round_to' do
    it "should return float rounded to specified precision" do
      expect(0.5122.round_to).to eql(1.0)
      expect(0.3333.round_to(1)).to eql(0.3)
      expect(0.33335.round_to(2)).to eql(0.33)
      expect(0.33335.round_to(4)).to eql(0.3334)
    end
  end

  describe '#to_currency_s' do
    it { expect(0.333.to_currency_s).to be_a(String) }

    it "should prefix string with currency symbol" do
      expect(5.12.to_currency_s.include?("$")).to eql(true)
    end

    it "should pad with zeros for cents" do
      expect(5.0.to_currency_s).to eql("$5.00")
    end
    it "should round string to nearest tenth" do
      expect(0.333.to_currency_s).to eql("$0.33")
    end
    it "should add commas to long numbers" do
      expect(500000000000.0.to_currency_s).to eql("$500,000,000,000.00")
      expect(50000000000.0.to_currency_s).to eql("$50,000,000,000.00")
      expect(5000000000.0.to_currency_s).to eql("$5,000,000,000.00")
    end
  end
end

describe SimpleModel::ExtendCore, 'String.rb' do
  before(:all) do
    include SimpleModel::ExtendCore
  end
  describe '#safe_datetime_string' do
    it "should set US formated datetime string to international" do
      expect("12/31/2010".safe_datetime_string).to eql("2010-12-31")
      expect("12/31/2010T23:31:59".safe_datetime_string).to eql("2010-12-31T23:31:59")
      expect("12/31/2010 23:31:59".safe_datetime_string).to eql("2010-12-31 23:31:59")
    end
  end

  describe '#to_b' do
    it "should return a Boolean" do
      expect("1".to_b.class).to eql(TrueClass)
      expect("".to_b.class).to eql(FalseClass)
    end
    it "should return true if string is '1' or 't' or 'true'"do
      ['1','t','true'].each do |s|
        expect(s.to_b).to eql(true)
      end
    end
  end

  describe '#to_date' do
    context "US formatted date strings" do
    it {expect {"12/31/2010".to_date}.to_not raise_error }
    it {expect("12/31/2010".to_date).to be_a(Date)}
    it {expect("12/31/2010".to_date).to eql(Date.parse("2010-12-31"))}
  end
    context "C# JSON datetime stamp" do
      it { expect {"\/Date(1310669017000)\/".to_date}.to_not raise_error }
      it { expect("\/Date(1310669017000)\/".to_date).to be_a(Date) }
      it { expect("\/Date(1310669017000)\/".to_date).to eql(Date.parse("2011-07-14")) }
    end
  end

  describe '#to_time' do
    context "US formatted date strings" do
      it { expect {"12/31/2010 12:00:00".to_time}.to_not raise_error }
      it { expect("12/31/2010 12:00:00".to_time).to be_kind_of(Time) }
      it { expect("12/31/2010 12:00:00".to_time).to eql(Time.parse("2010-12-31 12:00:00")) }
    end

    context "C# JSON datetime stamp" do
      it { expect {"\/Date(1310669017000)\/".to_time}.to_not raise_error }
      it { expect("\/Date(1310669017000)\/".to_time).to be_kind_of(Time) }
    end
  end

  describe '#to_f' do
    context "contains non-numeric values" do
      it { expect("$5,000.006".to_f).to eql(5000.006) }
    end
  end

  describe '#to_currency' do
    context "contains non-numeric values" do
      it { expect("$5,000.006".to_currency).to eql(BigDecimal("5000.006")) }
    end
  end
end
