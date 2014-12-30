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
# init           1.260000   0.000000   1.260000 (  1.258683)
# init w/attrs   2.230000   0.000000   2.230000 (  2.235730)
# get            1.510000   0.000000   1.510000 (  1.506397)
# get?           1.590000   0.000000   1.590000 (  1.591133)
# set            2.550000   0.000000   2.550000 (  2.558869)
# --------------------------------------- total: 9.140000sec

#                    user     system      total        real
# init           1.250000   0.000000   1.250000 (  1.245372)
# init w/attrs   2.260000   0.000000   2.260000 (  2.259318)
# get            1.500000   0.010000   1.510000 (  1.498191)
# get?           1.580000   0.000000   1.580000 (  1.581373)
# set            2.570000   0.000000   2.570000 (  2.571547)

