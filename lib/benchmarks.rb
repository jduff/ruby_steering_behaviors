require 'benchmark'
require 'vector2d'

Benchmark.bm do |x|
  a = Vector2d.new(23,45)
  
  x.report do
    1.upto(100000) do
      a.normalize!
    end
  end
end
