class Vector2d
  attr_reader :x, :y
  
  def initialize(x=0,y=0)
    clear_memo
    @x = Float(x)
    @y = Float(y)
  end

  def clear_memo
    @length = nil
    @length_sq = nil
    @normalized = false
  end

  def length
    @length ||= Math.sqrt(length_sq)
  end

  def length_sq
    @length_sq ||= @x*@x + @y*@y
  end
  
  def normalize!
    return self if @normalized
    @x /= length
    @y /= length
    clear_memo
    @normalized = true
    self
  end

  def x=(x)
    clear_memo
    @x = x
  end
  
  def y=(y)
    clear_memo
    @y = y
  end


  def add!(v)
    self.x += v.x
    self.y += v.y
    self
  end

  def div!(n)
    self.x /= n
    self.y /= n
    self
  end

  def mult!(n)
    self.x *= n
    self.y *= n
    self
  end
  
  def truncate!(max)
    teta = Math.acos(x/length)
    self.x = max * Math.cos(teta)
    self.y = max * Math.sin(teta)
    self
  end

  def truncate(max)
    self.normalize!.mult!(max)# if length > max
  end

  def dot(vector)
    @x*vector.x + @y*vector.y
  end

  def perp
    Vector2d.new(-@y, @x)
  end

  def to_s
    format("<%.3f,%.3f>", @x, @y)
  end
end

#   def normalize
#     Vector2d.new(@x/length, @y/length)
#   end
#   def add(v)
#     Vector2d.new(@x + v.x, @y + v.y)
#   end
#   def div(n)
#     Vector2d.new(@x/n, @y/n)
#   end
#   def mult(n)
#     Vector2d.new(@x*n, @y*n)
#   end
  
#   def truncate(max)
#     #teta = Math.acos(x/length)
#     #Vector2d.new(n * Math.cos(teta), n * Math.sin(teta))
#     self.normalize! * max if length > max
#   end
