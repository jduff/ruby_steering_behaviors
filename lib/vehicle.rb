class BaseGameEntity
  attr_accessor :pos, :scale, :b_radius

  def initialize
    @pos = Vector2d.new
  end

  def render
  end

  def update(time_elapsed)
  end
end

class SteeringBehavior
  def initialize(vehicle)
    @vehicle = vehicle
    @steering = Vector2d.new
    @target = Vector2d.new(10,10)
  end

  def seek(target)
    desired_velocity = target.sub!(@vehicle.pos).mult!(@vehicle.max_speed)
    desired_velocity.sub!(@vehicle.vel)
  end

  def calculate
    @steering.zero
    seek(@target)
  end
  
end

class Vehicle
  attr_reader :pos, :vel, :head, :side,
  :mass, :max_speed, :max_force, :max_turn_rate

  def initialize
    @pos = Vector2d.new
    @vel = Vector2d.new
    @head = Vector2d.new(1,0)
    @side = Vector2d.new
    @mass = 10.0
    @max_speed = 10.0
    @max_force = 5.0
    @max_turn_rate = 2.0

    @steering = SteeringBehavior.new(self)
    
  end

  def update(e_time)
    force = @steering.calculate
    aceleration = force.div!(@mass)
    @vel.add!(aceleration.mult!(e_time))
    @vel.truncate!(@max_speed)
    @pos.add!(@vel.mult!(e_time))
    if(@vel.length_sq > 0.00000001)
      @head = @vel.normalize!
      @side = @head.perp
    end
  end

  def to_s
    @pos
  end
  
end
