class Viewport
  attr_reader :x, :y, :w, :h, :virtual_w, :virtual_h
  
  def initialize(opts={})
    default_opts = {
      :x => 0, :y => 0,
      :virtual_w => opts[:w], :virtual_h => opts[:h]
    }
    opts = default_opts.merge!(opts)
    
    @x = opts[:x]
    @y = opts[:y]
    @w = Float(opts[:w])
    @h = Float(opts[:h])
    @virtual_w = Float(opts[:virtual_w])
    @virtual_h = Float(opts[:virtual_h])
  end

  def add_entity(entity)
    @entities ||= []
    @entities << entity
  end

  def on(event, &block)
    @listening ||= Hash.new
    @listening[event] = block
  end

  def ex(event)
    puts @listening
    @listening[event].call
  end
  
  def update(elapsed_t)
    @entities.each do |e|
      e.update(elapsed_t)
      e.pos.x = virtual_w if e.pos.x < 0
      e.pos.y = virtual_h if e.pos.y < 0
      e.pos.x = 0 if e.pos.x > virtual_w
      e.pos.y = 0 if e.pos.y > virtual_h
    end
  end

  def draw
    last_viewport = Render.viewport
    Render.set_viewport(self)
    @entities.each do |e|
      e.draw
    end
    Render.borders(:x => @x, :y => @y, :w => @w, :h => @h)
    Render.set_viewport(last_viewport)
  end

  # Screen coordinates to local viewport
  def to_screen_x(x)
    @x + x * @w / @virtual_w
  end

  def to_screen_y(y)
    @y + y * @h / @virtual_h
  end

  def to_viewport_x(x)
    (x - @x) * @virtual_w / @w
  end

  def to_viewport_y(y)
    (y - @y) * @virtual_h / @h
  end

  def screen_factor_x
    @w/@virtual_w
  end

  def screen_factor_y
    @h/@virtual_h
  end
end
