$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'benchmark'
require 'simple_model'

class BenchClass < SimpleModel::Base
  has_attribute :foo
  has_boolean :bool
  has_int :num
  has_date :date, :default => :today, :allow_blank => false
  has_time :time, :allow_blank => true
  has_float :float, :default => 0.0
  has_decimal :dec

  def today
    Date.today
  end
end

puts `ruby -v`
Benchmark.bmbm do |b|
  b.report("init") do
    30000.times.each  do
      BenchClass.new()
    end
  end

  b.report("init w/attrs") do
    30000.times.each  do
      BenchClass.new(:foo => nil,
        :bool => false, 
        :num => 1, 
        :dec => "12.4", 
        :time => Time.now,
        :float => 1.0
        )
    end
  end

  b.report("get") do
    30000.times.each  do
      bc = BenchClass.new
      bc.foo
      bc.bool
      bc.num
      bc.dec
      bc.date
      bc.time
      bc.float
    end
  end

  b.report("get?") do
    30000.times.each  do
      bc = BenchClass.new
      bc.foo?
      bc.bool?
      bc.num?
      bc.dec?
      bc.date?
      bc.time?
      bc.float?
    end
  end

  b.report("set") do
    30000.times.each  do
      bc = BenchClass.new
      bc.foo = nil
      bc.bool = true
      bc.num = 1
      bc.dec = '12.4'
      bc.date = "" # check blank
      bc.time = Time.now
      bc.float = 10.0
    end
  end
end

# ruby 2.1.5p273 (2014-11-13 revision 48405) [x86_64-darwin14.0]

# Rehearsal ------------------------------------------------
# init           0.170000   0.000000   0.170000 (  0.180832)
# init w/attrs   1.340000   0.010000   1.350000 (  1.332035)
# get            0.720000   0.000000   0.720000 (  0.728295)
# get?           0.830000   0.000000   0.830000 (  0.829985)
# set            1.460000   0.000000   1.460000 (  1.463964)
# --------------------------------------- total: 4.530000sec

#                    user     system      total        real
# init           0.170000   0.000000   0.170000 (  0.167929)
# init w/attrs   1.330000   0.000000   1.330000 (  1.327625)
# get            0.730000   0.000000   0.730000 (  0.727745)
# get?           0.830000   0.000000   0.830000 (  0.829802)
# set            1.490000   0.010000   1.500000 (  1.498151)

