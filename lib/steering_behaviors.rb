class SteeringBehaviors
  attr_reader :behaviors, :predicted, :look_ahead_time
  
  def initialize(vehicle)
    @vehicle = vehicle
    @steering = Vector2d.new
    @behaviors = Hash.new
  end

  def seek(target_pos)
    desired_velocity = (target_pos - @vehicle.pos).normalize * @vehicle.max_speed
    return desired_velocity - @vehicle.vel
  end

  def flee(target_pos)
    desired_velocity = (@vehicle.pos - target_pos).normalize * @vehicle.max_speed
    return desired_velocity - @vehicle.vel
  end

  def arrive(target_pos, deceleration = :normal)
    dec_opts = {
      :fast => 0.5,
      :normal => 1,
      :slow => 2
    }
    to_target = target_pos - @vehicle.pos
    dist = to_target.length

    if dist > 0
      deceleration_tweaker = 1.2
      speed = dist / (deceleration_tweaker*dec_opts[deceleration])
      speed = [speed, @vehicle.max_speed].min
      desired_velocity = to_target * speed / dist
      return desired_velocity - @vehicle.vel
    end
    return Vector2d.new(0,0)
  end

  def pursuit(evader)
    to_evader = evader.pos - @vehicle.pos
    relative_heading = @vehicle.head.dot(evader.head)

    if to_evader.dot(@vehicle.head) > 0 && relative_heading < -0.95
      return seek(evader.pos)
    end
    
    @look_ahead_time = (to_evader / (@vehicle.max_speed + evader.vel.length)).length
    @predicted = evader.pos + evader.vel * @look_ahead_time
    return seek(evader.pos + evader.vel * @look_ahead_time)
  end

  def calculate
    @steering.zero!
    if @behaviors[:seek]
      @steering = seek(@vehicle.target) if @vehicle.target
    end

    if @behaviors[:flee]
      @steering = flee(@vehicle.target) if @vehicle.target
    end

    if @behaviors[:arrive]
      @steering = arrive(@vehicle.target, :fast) if @vehicle.target
    end

    if @behaviors[:pursuit]
      @steering = pursuit(@vehicle.evader) if @vehicle.evader
    end
    @steering
  end

  def to_s
    @steering.to_s
  end
end
