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

  def zero!
    self.x = 0
    self.y = 0
  end

  def zero?
    @x == 0 && @y == 0
  end

  def length
    @length ||= Math.sqrt(length_sq)
  end

  def length_sq
    @length_sq ||= @x*@x + @y*@y
  end

  def x=(x)
    clear_memo
    @x = Float(x)
  end
  
  def y=(y)
    clear_memo
    @y = Float(y)
  end

  def normalize
    Vector2d.new(@x/length, @y/length)
  end

  def +(v)
    Vector2d.new(@x + v.x, @y + v.y)
  end
  
  def /(n)
    Vector2d.new(@x/n, @y/n)
  end
  
  def *(n)
    Vector2d.new(@x*n, @y*n)
  end

  def -(v)
    Vector2d.new(@x - v.x, @y - v.y)
  end

  def normalize!
    return self if @normalized
    @x /= length
    @y /= length
    clear_memo
    @normalized = true
    self
  end
  
  def truncate!(max)
    return if length < max
    normalize!
    self.x *= max
    self.y *= max
  end

  def dot(vector)
    @x*vector.x + @y*vector.y
  end

  def perp
    Vector2d.new(-@y, @x)
  end

  def angle
    theta = Math.acos(-@y/length) * 180 / Math::PI
    if @x < 0
      return theta * -1
    end
    
    return theta
  end

  def to_s
    format("(%.2f, %.2f)", @x, @y)
  end
end
