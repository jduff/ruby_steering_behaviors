class Render
  @viewport = nil
  
  class << self
    attr_accessor :debug, :viewport

    def set_window(window)
      @window = window
    end

    def set_viewport(viewport)
      @viewport = viewport
    end

    def set_font(font)
      @font = font
    end

    def set_graphics(graphics)
      @graphics = graphics
    end
    
    def add_list_item(text)
      @items ||= []
      @items << text
    end

    def borders(opts={})
      
      @window.
        draw_line(opts[:x], opts[:y], 0xffff0000,
                  opts[:x]+opts[:w], opts[:y], 0xffff0000)
      @window.
        draw_line(opts[:x]+opts[:w], opts[:y], 0xffff0000,
                  opts[:x]+opts[:w], opts[:y]+opts[:h], 0xffff0000)

      @window.
        draw_line(opts[:x]+opts[:w], opts[:y]+opts[:h], 0xffff0000,
                  opts[:x], opts[:y]+opts[:h], 0xffff0000)

      @window.
        draw_line(opts[:x], opts[:y]+opts[:h], 0xffff0000,
                  opts[:x], opts[:y], 0xffff0000)
    end
    
    def image(name, opts={})
      default_opts = {
        :x => 0,
        :y => 0,
        :angle => 0,
        :align_x => :center,
        :align_y => :middle,
        :color => 0xffffffff,
        :factor => 1,
        :z_order => ZOrder::Entity
      }
      opts = default_opts.merge!(opts)
      adjust_to_viewport(opts)
      
      @graphics[name].
        draw_rot(opts[:x],
                 opts[:y],
                 opts[:z_order],
                 opts[:angle],
                 get_alignment(opts[:align_x]),
                 get_alignment(opts[:align_y]),
                 opts[:factor],
                 opts[:factor],
                 opts[:color])
    end
    
    def text(text, opts={})
      default_opts = {
        :x => 0,
        :y => 0,
        :align_x => :center,
        :align_y => :top,
        :color => 0xffeeeeee,
        :factor => 1,
        :z_order => ZOrder::UI
      }
      opts = default_opts.merge!(opts)
      #adjust_to_viewport(opts)
      
      @font.
        draw_rel(text,
                 opts[:x],
                 opts[:y],
                 opts[:z_order],
                 get_alignment(opts[:align_x]),
                 get_alignment(opts[:align_y]),
                 opts[:factor],
                 opts[:factor],
                 opts[:color])
    end

    def list(opts={})
      default_opts = {
        :x => 0,
        :y => 0,
        :height => 30,
        :factor => 1
      }
      opts = default_opts.merge!(opts)
      adjust_to_viewport(opts)
      
      @items.each_with_index do |t,i|
        text(t,
             :align_x => :left,
             :y => opts[:y] + i * opts[:height] * opts[:factor],
             :x => opts[:x],
             :factor => opts[:factor])
      end
      @items = []
    end
    
    def get_alignment(type)
      case type
      when :left
        0
      when :top
        0
      when :center
        0.5
      when :middle
        0.5
      when :right
        1
      when :bottom
        1
      end
    end

    def adjust_to_viewport(opts)
      if @viewport
        opts[:x] = @viewport.to_screen_x(opts[:x])
        opts[:y] = @viewport.to_screen_y(opts[:y])
        opts[:factor] = @viewport.screen_factor_x * opts[:factor]
      end
    end
  end
end

      # @window.
      #   draw_quad(opts[:x], opts[:y], 0xffffffff,
      #             opts[:x]+opts[:w], opts[:y], 0xffffffff,
      #             opts[:x], opts[:y]+opts[:h], 0xffffffff,
      #             opts[:x]+opts[:w], opts[:y]+opts[:h], 0xff000000,
      #             ZOrder::Viewport,
      #             :additive)
