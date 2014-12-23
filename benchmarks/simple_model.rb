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
# init           1.360000   0.000000   1.360000 (  1.364654)
# init w/attrs   2.510000   0.000000   2.510000 (  2.512509)
# get            1.620000   0.000000   1.620000 (  1.619021)
# get?           1.700000   0.000000   1.700000 (  1.697857)
# set            2.720000   0.000000   2.720000 (  2.724271)
# --------------------------------------- total: 9.910000sec

#                    user     system      total        real
# init           1.350000   0.000000   1.350000 (  1.352561)
# init w/attrs   2.530000   0.010000   2.540000 (  2.532518)
# get            1.610000   0.000000   1.610000 (  1.613509)
# get?           1.690000   0.000000   1.690000 (  1.693701)
# set            2.700000   0.000000   2.700000 (  2.698375)

