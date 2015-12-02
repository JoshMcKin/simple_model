$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'benchmark/ips'
require 'simple_model'

puts `ruby -v`


# HotTub uses persisted blocks in several places.

# Tests performance of passing a known block to block call or yield.


us = "07/14/2011 13:43:37"
iso = "2011-07-14 13:43:37"
json = "\/Date(1310669017000)\/"

puts us.to_time
puts iso.to_time
puts json.to_time


Benchmark.ips do |x|

  x.report("date iso") do
    iso.to_date
  end

  x.report("date us") do
    us.to_date
  end

  x.report("date json") do
    json.to_date
  end

  x.report("time iso") do
    iso.to_time
  end

  x.report("time us") do
    us.to_time
  end

  x.report("time json") do
    json.to_time
  end

  x.compare!
end

# V-1.4.3
# ruby 2.2.3p173 (2015-08-18 revision 51636) [x86_64-darwin14]
# Calculating -------------------------------------
#             date iso    12.056k i/100ms
#              date us    11.120k i/100ms
#            date json     9.113k i/100ms
#             time iso     2.409k i/100ms
#              time us     2.098k i/100ms
#            time json    10.795k i/100ms
# -------------------------------------------------
#             date iso    200.936k (± 2.9%) i/s -      1.013M
#              date us    184.495k (± 3.3%) i/s -    922.960k
#            date json    130.588k (± 1.4%) i/s -    656.136k
#             time iso     27.103k (± 1.7%) i/s -    137.313k
#              time us     23.126k (± 1.0%) i/s -    117.488k
#            time json    187.509k (± 2.4%) i/s -    939.165k

# Comparison:
#             date iso:   200935.7 i/s
#            time json:   187508.9 i/s - 1.07x slower
#              date us:   184494.7 i/s - 1.09x slower
#            date json:   130588.2 i/s - 1.54x slower
#             time iso:    27103.4 i/s - 7.41x slower
#              time us:    23126.3 i/s - 8.69x slower

# V-1.4.2
# ruby 2.2.3p173 (2015-08-18 revision 51636) [x86_64-darwin14]
# Calculating -------------------------------------
#             date iso     3.499k i/100ms
#              date us     2.997k i/100ms
#            date json     2.391k i/100ms
#             time iso     2.484k i/100ms
#              time us     2.219k i/100ms
#            time json     1.760k i/100ms
# -------------------------------------------------
#             date iso     41.965k (± 1.9%) i/s -    209.940k
#              date us     35.729k (± 1.2%) i/s -    179.820k
#            date json     27.491k (± 1.5%) i/s -    138.678k
#             time iso     27.247k (± 1.6%) i/s -    136.620k
#              time us     23.937k (± 1.2%) i/s -    119.826k
#            time json     19.031k (± 1.4%) i/s -     96.800k

# Comparison:
#             date iso:    41964.9 i/s
#              date us:    35729.2 i/s - 1.17x slower
#            date json:    27491.2 i/s - 1.53x slower
#             time iso:    27247.5 i/s - 1.54x slower
#              time us:    23937.0 i/s - 1.75x slower
#            time json:    19031.1 i/s - 2.21x slower