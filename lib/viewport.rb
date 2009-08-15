class Viewport
  attr_accessor :x, :y, :w, :h, :virtual_w, :virtual_h, :entities
  
  def initialize(opts={})
    default_opts = {
      :x => 0, :y => 0,
      :virtual_w => opts[:w], :virtual_h => opts[:h],
      :window => opts[:window]
    }
    opts = default_opts.merge!(opts)
    
    @x = opts[:x]
    @y = opts[:y]
    @w = Float(opts[:w])
    @h = Float(opts[:h])
    @virtual_w = Float(opts[:virtual_w])
    @virtual_h = Float(opts[:virtual_h])
    @window = opts[:window]

    @entities = Array.new
    @events = Hash.new
  end

  def mouse_pos
    Vector2d.new(to_viewport_x(@window.mouse_x), to_viewport_y(@window.mouse_y))
  end

  def on(event, &block)
    @events[event] = block
  end

  def fire(event)
    if @events[event] && inside?(@window.mouse_x, @window.mouse_y)
      puts "Viewport: #{event}" if Game::debug
      @events[event].call(self)
    end
  end

  def inside?(x,y)
    x >= @x && x < (@x + @w) && y >= @y && y < (@y + @h)
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
    Render.clip_to(@x,@y,@w,@h) do
      Render.set_viewport(self)
      @entities.each do |e|
        e.draw
      end    
    end
    Render.set_viewport(last_viewport)
    
    Render.borders(:x => @x, :y => @y, :w => @w, :h => @h)
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
