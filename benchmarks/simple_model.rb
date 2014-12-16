$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'benchmark'
require 'simple_model'

class BenchClass < SimpleModel::Base
  has_int :num
  has_date :date, :default => :today
  has_time :time, :allow_blank => true
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
      BenchClass.new(:num => 1, :dec => "12.4", :time => Time.now)
    end
  end

  b.report("get") do
    30000.times.each  do
      klass = BenchClass.new
      klass.num
      klass.dec
      klass.date
      klass.time
    end
  end

  b.report("set") do
    30000.times.each  do
      klass = BenchClass.new
      klass.num = 1
      klass.dec = '12.4'
      klass.date = "" # check blank
      klass.time = Time.now
    end
  end
end


# ruby 2.1.5p273 (2014-11-13 revision 48405) [x86_64-darwin14.0]

# Rehearsal ------------------------------------------------
# init           1.470000   0.010000   1.480000 (  1.469134)
# init w/attrs   2.710000   0.000000   2.710000 (  2.711199)
# get            1.870000   0.000000   1.870000 (  1.874468)
# set            3.030000   0.000000   3.030000 (  3.034562)
# --------------------------------------- total: 9.090000sec

#                    user     system      total        real
# init           1.460000   0.000000   1.460000 (  1.462464)
# init w/attrs   2.700000   0.000000   2.700000 (  2.694756)
# get            1.890000   0.000000   1.890000 (  1.888724)
# set            2.990000   0.000000   2.990000 (  2.999166)
