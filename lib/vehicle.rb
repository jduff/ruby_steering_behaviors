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

class Vehicle
  attr_reader :velocity, :heading, :side,
  :mass, :max_speed, :max_force, :max_turn_rate
end

