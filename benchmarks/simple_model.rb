class BenchClass < SimpleModel::Base
  has_int :num
  has_date :date, :default => :today
  has_decimal :dec

  def today
    Date.today
  end
end
Benchmark.bm do |b|
  b.report("initialize") do
    30000.times.each  do
      BenchClass.new()
    end
  end

  b.report("initialize with attrs") do
    30000.times.each  do
      BenchClass.new(:num => 1, :dec => "12.4")
    end
  end
  
  b.report("get") do
    30000.times.each  do
      klass = BenchClass.new
      klass.num
      klass.dec
      klass.date
    end
  end

  b.report("set") do
    30000.times.each  do
      klass = BenchClass.new
      klass.num = 1
      klass.dec = '12.4'
      klass.date = "2014-12-25"
    end
  end
end
