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
# init           0.940000   0.000000   0.940000 (  0.944332)
# init w/attrs   2.000000   0.010000   2.010000 (  2.001086)
# get            1.190000   0.000000   1.190000 (  1.192450)
# get?           1.290000   0.000000   1.290000 (  1.283052)
# set            2.330000   0.000000   2.330000 (  2.330751)
# --------------------------------------- total: 7.760000sec

#                    user     system      total        real
# init           0.930000   0.000000   0.930000 (  0.925949)
# init w/attrs   2.020000   0.000000   2.020000 (  2.019487)
# get            1.200000   0.000000   1.200000 (  1.198100)
# get?           1.290000   0.000000   1.290000 (  1.293631)
# set            2.310000   0.000000   2.310000 (  2.311806)

