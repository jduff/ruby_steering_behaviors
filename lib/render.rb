class Render
  @viewport = nil
  @row = 0
  
  class << self
    attr_accessor :viewport

    def set_window(window)
      @window = window
    end

    def set_viewport(viewport)
      @viewport = viewport
    end

    def list_item(text)
      @items ||= []
      @items << text
    end

    def load_images(images)
      @images ||= {}
      images.each_pair do |k,v|
        @images[k] = Gosu::Image.new(@window, v,true)
      end
    end

    def load_fonts(fonts)
      @fonts ||= {}
      fonts.each_pair do |k,v|
        @fonts[k] = Gosu::Font.new(@window, v[:name], v[:size])
      end
    end

    def clip_to(x, y, w, h, &block)
      @window.clip_to(x.to_i, y.to_i, w.to_i, h.to_i, &block)
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
        :z_order => :entity
      }
      opts = default_opts.merge!(opts)
      adjust_to_viewport(opts)
      
      @images[name].
        draw_rot(opts[:x],
                 opts[:y],
                 z_order(opts[:z_order]),
                 opts[:angle],
                 alignment(opts[:align_x]),
                 alignment(opts[:align_y]),
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
        :color => 0xffffffff,
        :factor => 1,
        :z_order => :ui,
        :font => :default
      }
      opts = default_opts.merge!(opts)
      #adjust_to_viewport(opts)
      
      @fonts[opts[:font]].
        draw_rel(text,
                 opts[:x],
                 opts[:y],
                 z_order(opts[:z_order]),
                 alignment(opts[:align_x]),
                 alignment(opts[:align_y]),
                 opts[:factor],
                 opts[:factor],
                 opts[:color])
    end

    def text_list(opts={})
      @row = 0
      yield self
      render_list(opts)
    end
    
    def render_list(opts={})
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

    def circle(cx, cy, r)
      image(:circle,
            :x => cx, :y => cy,
            :factor => r*2/100.0,
            :color => 0xffffffff)
    end

    def borders(opts={})
      @window.
        draw_line(opts[:x], opts[:y], 0xffff0000,
                  opts[:x]+opts[:w], opts[:y], 0xffff0000, z_order(:ui))
      @window.
        draw_line(opts[:x]+opts[:w], opts[:y], 0xffff0000,
                  opts[:x]+opts[:w], opts[:y]+opts[:h], 0xffff0000, z_order(:ui))

      @window.
        draw_line(opts[:x]+opts[:w], opts[:y]+opts[:h], 0xffff0000,
                  opts[:x], opts[:y]+opts[:h], 0xffff0000, z_order(:ui))

      @window.
        draw_line(opts[:x], opts[:y]+opts[:h], 0xffff0000,
                  opts[:x], opts[:y], 0xffff0000, z_order(:ui))
    end

    def adjust_to_viewport(opts)
      if @viewport
        opts[:x] = @viewport.to_screen_x(opts[:x])
        opts[:y] = @viewport.to_screen_y(opts[:y])
        opts[:factor] = @viewport.screen_factor_x * opts[:factor]
      end
    end

    private
    def alignment(alignment)
      @alignments ||= {
        :left => 0,
        :top => 0,
        :center => 0.5,
        :middle => 0.5,
        :right => 1,
        :bottom => 1
      }
      @alignments[alignment]
    end

    def z_order(order)
      @orders ||= {
        :viewport => 0,
        :background => 1,
        :entity => 2,
        :ui => 3,
        :pointer => 4,
        :debug => 5
      }
      @orders[order]
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
