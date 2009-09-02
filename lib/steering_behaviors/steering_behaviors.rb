class SteeringBehaviors
  # For debugging
  attr_reader :force, :predicted_pursuit, :predicted_evade,
  :distance_to_target, :look_ahead_time, :wander_target,
  :wander_center, :wander_radius, :wander_angle,
  :wander_distance, :target_world

  # Initialize the steering behaviors
  def initialize(agent)
    # Agent should respond to:
    # pos (position vector)
    # vel (velocity vector)
    # heading (heading vector)
    # speed (velocity's length)
    # max_speed (maximum speed value)
    @agent = agent
    @force = Vector2d.new
    @behaviors = Hash.new
    @wander_target = Vector2d.new(clamped_rand, clamped_rand)
    @wander_radius = 120
    @wander_distance = 240.0
  end

  # Activate a specific behavior
  def activate(behavior)
    @behaviors[behavior] = true
  end

  # Deactivate a specific behavior
  def deactivate(behavior)
    @behaviors[behavior] = false
  end

  # Seek a target position
  def seek(target_pos)
    desired_velocity = (target_pos - @agent.pos).normalize * @agent.max_speed
    return desired_velocity - @agent.vel
  end

  # Flee from a target position
  def flee(target_pos)
    desired_velocity = (@agent.pos - target_pos).normalize * @agent.max_speed
    return desired_velocity - @agent.vel
  end

  # Arrive at a target position
  def arrive(target_pos, deceleration = :normal)
    dec_opts = {
      :fast => 0.5,
      :normal => 1,
      :slow => 2
    }
    deceleration_tweaker = 1.2
    
    to_target = target_pos - @agent.pos
    @distance_to_target = to_target.length

    if @distance_to_target > 0
      speed = @distance_to_target / (deceleration_tweaker*dec_opts[deceleration])
      speed = [speed, @agent.max_speed].min
      desired_velocity = to_target * speed / @distance_to_target
      return desired_velocity - @agent.vel
    end
    return Vector2d.new(0,0)
  end

  # Pursuit an evader agent
  def pursuit(evader)
    to_evader = evader.pos - @agent.pos
    
    relative_heading = @agent.heading.dot(evader.heading)
    if to_evader.dot(@agent.heading) > 0 && relative_heading < -0.95
      @predicted_pursuit = nil
      @look_ahead_time = nil
      return seek(evader.pos)
    end
    
    @look_ahead_time = to_evader.length / (@agent.max_speed + evader.speed)
    @predicted_pursuit = evader.pos + evader.vel * @look_ahead_time
    return seek(@predicted_pursuit)
  end

  # Evade a pursuer agent
  def evade(pursuer)
    to_pursuer = pursuer.pos - @agent.pos
    
    @look_ahead_time = to_pursuer.length / (@agent.max_speed + pursuer.speed)
    @predicted_evade = pursuer.pos + pursuer.vel * @look_ahead_time 
    return flee(@predicted_evade)
  end

  # Wander about
  def wander
    wander_jitter = 10

    @wander_target += Vector2d.new(clamped_rand * wander_jitter, clamped_rand * wander_jitter)
    @wander_target.normalize!
    @wander_angle = @wander_target.angle
    @wander_target *= wander_radius
    target_local = @wander_target + Vector2d.new(0, wander_distance)
    @target_world = Vector2d.point_to_world(target_local, @agent.heading, @agent.side, @agent.pos)

    circle_center = Vector2d.new(0, wander_distance)
    @wander_center = Vector2d.point_to_world(circle_center, @agent.heading, @agent.side, @agent.pos)
    
    return target_world - @agent.pos
  end
  
  # Calculate the steering force acting on the agent
  def calculate
    @force.zero!
    if @behaviors[:seek]
      @force += seek(@agent.target) if @agent.target
    end

    if @behaviors[:flee]
      @force += flee(@agent.target) if @agent.target
    end

    if @behaviors[:arrive]
      @force += arrive(@agent.target, :fast) if @agent.target
    end

    if @behaviors[:pursuit]
      @force += pursuit(@agent.evader) if @agent.evader
    end

    if @behaviors[:evade]
      @force += evade(@agent.pursuer) if @agent.pursuer
    end

    if @behaviors[:wander]
      @force += wander
    end
    
    return @force
  end

  private
  # Obtain a random number between -1 (inclusive) and 1 (exclusive)
  def clamped_rand
    2 * rand - 1
  end
end
