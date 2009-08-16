# -*- coding: utf-8 -*-
class Vehicle
  attr_reader :pos, :vel, :heading,# :side,
  :mass, :max_speed, :elapsed_time, :color, :max_force, :max_turn_rate
  attr_accessor :target, :evader, :pursuer

  def initialize(opts={})
    default_opts = {
      :max_force => 100,
      :max_turn_rate => 300,
      :mass => 1,
      :max_speed => 150,
      :color => 0xffffffff,
      :x => 0,
      :y => 0
    }
    opts = default_opts.merge!(opts)
    
    @pos = Vector2d.new(opts[:x], opts[:y])
    @accel = Vector2d.new
    @target = @evader = @pursuer = nil
    @vel = Vector2d.new
    @heading = Vector2d.new(0,-1)
    @mass = Float(opts[:mass])
    @max_speed = Float(opts[:max_speed])
    @max_force = Float(opts[:max_force])
    @max_turn_rate = Float(opts[:max_turn_rate])
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
    @accel.truncate!(@max_force)

    new_velocity = @vel + @accel * @elapsed_time / 1000.0
    a1 = @heading.radians
    a2 = new_velocity.radians
    if (a1 - a2).abs <= Math::PI
      @angle = (a1 - a2).abs
    else
      @angle = Math::PI * 2 - (a1 - a2).abs
    end
    #@angle = a1 + a2
      
    #@angle = Vector2d.angle(@heading, new_velocity)
    max_angle = (@max_turn_rate * Math::PI / 180)  / 1000
    
    if (a2.abs - a1.abs).abs > max_angle
      puts "@angle#{@angle} > max_angle#{max_angle} #{@angle > max_angle}" if (a1.angle != 0)
      if a2.abs > a1.abs
        if new_velocity.x > @heading.x
          signo = 1
        else
          signo = -1
        end
      else
        if new_velocity.x > @heading.x
          signo = -1
        else
          signo = 1
        end
      end
          
      @vel.x = signo * Math.sin(@angle) * new_velocity.length
      @vel.y = signo * Math.cos(@angle) * new_velocity.length
      #puts "@vel.x#{@vel.x} @vel.y#{@vel.y} newx#{newx} newy#{newy}"
      @vel = new_velocity
    else
      @vel = new_velocity
    end
    
    
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
      Render.list_item("@angle #{@angle}")
      
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
