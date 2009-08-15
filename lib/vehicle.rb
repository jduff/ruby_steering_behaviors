# -*- coding: utf-8 -*-
class Vehicle
  attr_reader :pos, :vel, :heading,# :side,
  :mass, :max_speed, :elapsed_time, :color#, :max_force, :max_turn_rate
  attr_accessor :target, :evader, :pursuer

  def initialize(opts={})
    default_opts = {
      :mass => 1,
      :max_speed => 150,
      :color => 0xffffffff,
      :x => 0.0,
      :y => 0.0
    }
    opts = default_opts.merge!(opts)
    
    @pos = Vector2d.new(opts[:x], opts[:y])
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
    debug if Game.debug
  end

  def speed
    @vel.length
  end

  def side
    @heading.perp
  end
  
  def debug
    Render.text_list(:x => @pos.x, :y => 50 + @pos.y, :height => 30) do
      Render.list_item "@mass #{@mass} @pos #{@pos}"
      Render.list_item("#{format("%.2f", @heading.angle)}° @heading #{@heading}")
      Render.list_item("#{format("%.2f", @vel.length)}u/s @vel #{@vel}") if @vel
      Render.list_item("#{format("%.2f", @accel.length)}u/s^2 @accel #{@accel}")
      
      @steering.debug(:distance_to_target, "%.2f")
      @steering.debug(:look_ahead_time, "%.2f")
      @steering.debug(:wander_angle, "%.2f")
    end

    # do we have a target to arrive, seek or flee from?
    Render.image(:crosshair,
                 :x => @target.x,
                 :y => @target.y,
                 :color => @color,
                 :factor => 0.5,
                 :z_order => :ui) if @target

    # predicted position in pursuit
    Render.image(:crosshair,
                 :x => @steering.predicted_pursuit.x,
                 :y => @steering.predicted_pursuit.y,
                 :color => @color) if @steering.predicted_pursuit

    # predicted position in evade
    Render.image(:crosshair,
                 :x => @steering.predicted_evade.x,
                 :y => @steering.predicted_evade.y,
                 :color => @color) if @steering.predicted_evade

    # wander target
    to_world = @steering.target_world
    Render.image(:crosshair,
                 :x => to_world.x,
                 :y => to_world.y,
                 :factor => 0.5,
                 :color => @color,
                 :z_order => :ui) if to_world

    # wander circle
    Render.circle(:x => @steering.wander_center.x,
                  :y => @steering.wander_center.y,
                  :r => @steering.wander_radius,
                  :color => @color) if @steering.wander_center
    
  end
end
