class Vehicle
  attr_reader :pos, :vel, :head,# :side,
  :mass, :max_speed#, :max_force, :max_turn_rate
  attr_accessor :target, :evader

  def initialize(opts={})
    default_opts = {
      :mass => 1,
      :max_speed => 150,
      :color => 0xffffffff
    }
    opts = default_opts.merge!(opts)
    
    @pos = Vector2d.new
    @acceleration = Vector2d.new
    @target = nil
    @evader = nil
    @vel = Vector2d.new
    @head = Vector2d.new(0,-1)
    @mass = Float(opts[:mass])
    @max_speed = Float(opts[:max_speed])
    @color = opts[:color]
    @steering = SteeringBehaviors.new(self)
  end

  def turn_on(behavior)
    @steering.behaviors[behavior] = true
  end

  def update(elapsed_t)
    @elapsed_time = elapsed_t
    
    @force = @steering.calculate
    @acceleration = @force / @mass
    
    @vel += @acceleration * @elapsed_time / 1000.0
    @vel.truncate!(@max_speed)
    @pos += @vel * @elapsed_time / 1000.0

    if @vel.length_sq > 0.0001
      @head = @vel.normalize
    end
  end

  def draw
    Render.image(:starfighter, :x => @pos.x, :y => @pos.y, :angle => @head.angle, :color => @color)
    Render.image(:crosshair, :x => @target.x, :y => @target.y, :color => 0xff00ff00, :factor => 0.5, :z_order => ZOrder::UI) if @target
    debug if Game.debug
    Render.image(:crosshair, :x => @steering.predicted.x, :y => @steering.predicted.y) if @steering.predicted
  end
  
  def debug
    Render.add_list_item("Position#{@pos}")
    Render.add_list_item("Head#{@head}")
    Render.add_list_item("Angle #{format("%.2f", @head.angle)}")
    Render.add_list_item("Velocity#{@vel}")
    Render.add_list_item("|vel|#{format("%.2f", @vel.length)}")
    Render.add_list_item("Acceleration#{@acceleration}")
    Render.add_list_item("|ac|#{format("%.2f", @acceleration.length)}")
    Render.add_list_item("Predicted#{@steering.predicted}")
    Render.add_list_item("|pre|#{format("%.2f", @steering.predicted.length)}") if @steering.predicted
    Render.add_list_item("Distance #{format("%.2f", (@pos - @target).length)}") if @target
    Render.add_list_item("lat #{format("%.2f", @steering.look_ahead_time)}") if @steering.look_ahead_time
    Render.list(:factor => 1, :x => @pos.x, :y => 100+@pos.y)
  end
end
