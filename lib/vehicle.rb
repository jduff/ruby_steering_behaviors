# -*- coding: utf-8 -*-
class Vehicle
  attr_reader :pos, :vel, :heading,# :side,
  :mass, :max_speed, :elapsed_time#, :max_force, :max_turn_rate
  attr_accessor :target, :evader, :pursuer

  def initialize(opts={})
    default_opts = {
      :mass => 1,
      :max_speed => 150,
      :color => 0xffffffff
    }
    opts = default_opts.merge!(opts)
    
    @pos = Vector2d.new
    @accel = Vector2d.new
    @target = @evader = @pursuer = nil
    @vel = Vector2d.new
    @heading = Vector2d.new(0,-1)
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
    @accel = @force / @mass
    
    @vel += @accel * @elapsed_time / 1000.0
    @vel.truncate!(@max_speed)
    @pos += @vel * @elapsed_time / 1000.0

    if @vel.length_sq > 0.0001
      @heading = @vel.normalize
    end
  end

  def draw
    Render.image(:starfighter, :x => @pos.x, :y => @pos.y, :angle => @heading.angle, :color => @color)
    Render.image(:crosshair, :x => @target.x, :y => @target.y, :color => 0xff00ff00, :factor => 0.5, :z_order => ZOrder::UI) if @target
    debug if Game.debug
    Render.image(:crosshair, :x => @steering.predicted.x, :y => @steering.predicted.y) if @steering.predicted
    to_world = @steering.target_world#Vector2d.point_to_world(@steering.wander_target, @heading, side, @pos) if @steering.wander_target
    Render.image(:crosshair, :x => to_world.x, :y => to_world.y, :factor => 0.5, :color => 0xff0000ff, :z_order => ZOrder::UI) if to_world
    
    Render.circle(@steering.wander_center.x, @steering.wander_center.y, @steering.wander_radius) if @steering.wander_center
  end

  def speed
    @vel.length
  end

  def side
    @heading.perp
  end
  
  def debug
    Render.text_list(:x => @pos.x, :y => 50 + @pos.y, :height => 30) do
      Render.list_item "@pos #{@pos}"
      Render.list_item("#{format("%.2f", @heading.angle)}° @heading #{@heading}")
      Render.list_item("#{format("%.2f", @vel.length)}u/s @vel #{@vel}") if @vel
      Render.list_item("#{format("%.2f", @accel.length)}u/s^2 @accel #{@accel}")
      
      @steering.debug(:predicted, "%.2f", :length)
      @steering.debug(:distance_to_target, "%.2f")
      @steering.debug(:look_ahead_time, "%.2f")
      @steering.debug(:wander_angle, "%.2f")
    end
  end
end
