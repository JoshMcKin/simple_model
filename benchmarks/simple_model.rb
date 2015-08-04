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

# ruby 2.2.2p95 (2015-04-13 revision 50295) [x86_64-darwin13]

# Rehearsal ------------------------------------------------
# init           0.140000   0.000000   0.140000 (  0.141798)
# init w/attrs   1.050000   0.000000   1.050000 (  1.050091)
# get            0.440000   0.000000   0.440000 (  0.449112)
# get?           0.560000   0.000000   0.560000 (  0.551089)
# set            0.920000   0.000000   0.920000 (  0.924776)
# --------------------------------------- total: 3.110000sec

#                    user     system      total        real
# init           0.130000   0.000000   0.130000 (  0.127565)
# init w/attrs   1.050000   0.010000   1.060000 (  1.050821)
# get            0.450000   0.000000   0.450000 (  0.453590)
# get?           0.560000   0.000000   0.560000 (  0.560942)
# set            0.950000   0.000000   0.950000 (  0.949407)

