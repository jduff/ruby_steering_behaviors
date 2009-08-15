class SteeringBehaviors
  attr_reader :behaviors
  
  # For debugging
  attr_reader :force, :predicted, :distance_to_target, :look_ahead_time,
  :wander_target, :wander_center, :wander_radius, :wander_angle, :wander_distance, :target_world
  
  def initialize(vehicle)
    @vehicle = vehicle
    @wander_target = Vector2d.new
    @force = Vector2d.new
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
    @distance_to_target = to_target.length

    if @distance_to_target > 0
      deceleration_tweaker = 1.2
      speed = @distance_to_target / (deceleration_tweaker*dec_opts[deceleration])
      speed = [speed, @vehicle.max_speed].min
      desired_velocity = to_target * speed / @distance_to_target
      return desired_velocity - @vehicle.vel
    end
    return Vector2d.new(0,0)
  end

  def pursuit(evader)
    to_evader = evader.pos - @vehicle.pos
    
    relative_heading = @vehicle.heading.dot(evader.heading)
    if to_evader.dot(@vehicle.heading) > 0 && relative_heading < -0.95
      @predicted = nil
      @look_ahead_time = nil
      return seek(evader.pos)
    end
    
    @look_ahead_time = to_evader.length / (@vehicle.max_speed + evader.speed)
    @predicted = evader.pos + evader.vel * @look_ahead_time
    return seek(@predicted)
  end

  def evade(pursuer)
    to_pursuer = pursuer.pos - @vehicle.pos
    
    @look_ahead_time = to_pursuer.length / (@vehicle.max_speed + pursuer.speed)
    @predicted = pursuer.pos + pursuer.vel * @look_ahead_time 
    return flee(@predicted)
  end

  def wander
    @wander_radius = 50
    @wander_distance = 240.0
    wander_jitter = 10

    @wander_target += Vector2d.new(clamped_rand * wander_jitter, clamped_rand * wander_jitter)
    @wander_target.normalize!
    @wander_angle = @wander_target.angle
    @wander_target *= wander_radius
    target_local = @wander_target + Vector2d.new(0, wander_distance)
    @target_world = Vector2d.point_to_world(target_local, @vehicle.heading, @vehicle.side, @vehicle.pos)

    circle_center = Vector2d.new(0, wander_distance)
    @wander_center = Vector2d.point_to_world(circle_center, @vehicle.heading, @vehicle.side, @vehicle.pos)
    
    return target_world - @vehicle.pos
  end

  def clamped_rand
    2 * rand - 1
  end
    

  def calculate
    @force.zero!
    if @behaviors[:seek]
      @force = seek(@vehicle.target) if @vehicle.target
    end

    if @behaviors[:flee]
      @force = flee(@vehicle.target) if @vehicle.target
    end

    if @behaviors[:arrive]
      @force = arrive(@vehicle.target, :fast) if @vehicle.target
    end

    if @behaviors[:pursuit]
      @force = pursuit(@vehicle.evader) if @vehicle.evader
    end

    if @behaviors[:evade]
      @force = evade(@vehicle.pursuer) if @vehicle.pursuer
    end

    if @behaviors[:wander]
      @force = wander
    end
    
    return @force
  end

  def debug(var, f_string, m_name = nil)
    res = send(var)
    if res && m_name
      Render.list_item("#{format(f_string, send(var).send(m_name))}  @#{var} #{send(var)}")
    elsif res
      Render.list_item("@#{var} #{format(f_string, send(var))}")
    end
  end
end
