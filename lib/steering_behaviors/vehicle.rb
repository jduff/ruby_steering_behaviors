# -*- coding: utf-8 -*-
class Vehicle
  attr_reader :pos, :vel, :heading, :mass, :color, :max_speed, :max_force, :max_turn_rate
  attr_accessor :target, :evader, :pursuer

  def initialize(opts={})
    default_opts = {
      :x => 0,
      :y => 0,
      :mass => 1,
      :color => 0xffffffff,
      :max_speed => 150,
      :max_force => 500,
      :max_turn_rate => 160
    }
    opts = default_opts.merge!(opts)

    
    @target = @evader = @pursuer = nil
    @vel = Vector2d.new
    @accel = Vector2d.new
    @heading = Vector2d.new(0,-1)
    
    @pos = Vector2d.new(opts[:x], opts[:y])
    @mass = Float(opts[:mass])
    @color = opts[:color]
    @max_speed = Float(opts[:max_speed])
    @max_force = Float(opts[:max_force])
    @max_turn_rate = Float(opts[:max_turn_rate])
    
    @steering = SteeringBehaviors.new(self)
  end

  def self.create(type, weight)
    # TODO: implement helper for easier definition of vehicles
    # type => pursuer, evader, wanderer, seeker, fleer
    # weight => very_light, light, normal, heavy, very_heavy
  end

  def activate(behavior)
    @steering.activate(behavior)
  end

  def deactivate(behavior)
    @steering.deactivate(behavior)
  end

  def update(elapsed_t)
    @force = @steering.calculate
    @accel = @force / @mass
    @accel.truncate!(@max_force)

    rads = Math::PI / 180
    new_velocity = @vel + @accel * elapsed_t
    @angle = Vector2d.angle(@heading, new_velocity) * rads
    max_angle = @max_turn_rate * rads * elapsed_t
    
    if @angle.abs > max_angle
      sign = Vector2d.sign(@heading, new_velocity)
      corrected_angle = @heading.radians + max_angle * sign
      @vel.x = Math.sin(corrected_angle) * new_velocity.length
      @vel.y = - Math.cos(corrected_angle) * new_velocity.length
    else
      @vel = new_velocity
    end
    
    @vel.truncate!(@max_speed)
    @pos += @vel * elapsed_t

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
      Render.list_item("@angle #{@angle}")

      Render.list_item("@distance_to_target #{format("%.2f", @steering.distance_to_target)}") if @steering.distance_to_target

      Render.list_item("@look_ahead_time #{format("%.2f", @steering.look_ahead_time)}") if @steering.look_ahead_time

      Render.list_item("@wander_angle #{format("%.2f", @steering.wander_angle)}") if @steering.wander_angle
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
