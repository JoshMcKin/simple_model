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
# init           0.150000   0.000000   0.150000 (  0.149609)
# init w/attrs   1.100000   0.000000   1.100000 (  1.101177)
# get            0.490000   0.000000   0.490000 (  0.491134)
# get?           0.600000   0.000000   0.600000 (  0.598875)
# set            1.170000   0.000000   1.170000 (  1.171242)
# --------------------------------------- total: 3.510000sec

#                    user     system      total        real
# init           0.140000   0.000000   0.140000 (  0.140109)
# init w/attrs   1.060000   0.000000   1.060000 (  1.055176)
# get            0.490000   0.000000   0.490000 (  0.491473)
# get?           0.600000   0.000000   0.600000 (  0.600557)
# set            1.200000   0.010000   1.210000 (  1.196884)

