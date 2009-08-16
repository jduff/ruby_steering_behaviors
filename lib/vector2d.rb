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
    if length != 0
      Vector2d.new(@x/length, @y/length)
    else
      Vector2d.new(0,0)
    end
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
    if length == 0
      @x = 0
      @y = 0
      clear_memo
      @normalized = true
    end
      
    return self if @normalized
    @x /= length
    @y /= length
    clear_memo
    @normalized = true
    self
  end
  
  def truncate!(max)
    return self if length < max
    normalize!
    self.x *= max
    self.y *= max
    self
  end

  def dot(vector)
    @x*vector.x + @y*vector.y
  end

  def perp
    Vector2d.new(@y, -@x)
  end

  def angle
    up = Vector2d.new(0,-1)
    theta = Vector2d.angle(self, up)
    if @x < 0
      return theta * -1
    end
    
    return theta
  end

  def sign(v2)
    Vector2d.sign(self,v2)
  end

  def radians
    theta = Math.acos(-@y/length)
    if @x < 0
      return theta * -1
    end
    
    return theta
  end

  def to_s
    format("(%.2f, %.2f)", @x, @y)
  end

  class << self

    def angle(v1, v2)
      dot_product = v1.normalize.dot(v2.normalize)
      dot_product = -1.0 if dot_product < -1.0
      dot_product = 1.0 if dot_product > 1.0
        
      return Math.acos(dot_product) * 180 / Math::PI #* signo
    end

    def sign(v1, v2)
      if v1.y * v2.x > v1.x*v2.y
        return -1
      else
        return 1
      end
    end
    
    def point_to_world(point, heading, side, pos)
      local_angle = heading.radians + point.radians
      
      x = -Math.sin(local_angle) * point.length
      y = Math.cos(local_angle) * point.length
      
      #x = point.x * Math.cos(local_angle) + point.y * Math.sin(local_angle)
      #y = -point.x * Math.sin(local_angle) + point.y * Math.cos(local_angle)
      
      world_point = Vector2d.new(x,y) + pos
      return world_point
    end
    
    def debug(vars)
      cadena = ""
      vars.each_pair do |k,v|
        cadena << "#{k}(#{v}) "
      end
      puts cadena
    end
  end
end
