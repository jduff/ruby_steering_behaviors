# -*- coding: utf-8 -*-
dir = File.expand_path(File.dirname(__FILE__) + '/lib')
$LOAD_PATH.unshift(dir)

begin
  require 'rubygems'
rescue LoadError
end

require 'render'
require 'fps'
require 'steering_behaviors'
require 'vector2d'
require 'vehicle'
require 'gosu'
require 'viewport'
require 'set'

module Keys
  include Gosu::Button
  @keys = {
    KbLeft => :left,
    MsLeft => :start,
    KbEscape => :cancel,
    KbUp => :zoom_in,
    KbDown => :zoom_out,
    MsWheelUp => :zoom_in,
    MsWheelDown => :zoom_out
  }

  def self.[](key)
    @keys[key]
  end
end
  

class Game < Gosu::Window
  @debug = true

  class << self
    attr_accessor :debug
  end
  
  def initialize
    @w = 1024
    @h = 768
    @fullscreen = false
    super(@w, @h, @fullscreen)
    
    @fps = FpsCounter.new
    @last_time = Gosu::milliseconds

    @events = Hash.new
    
    init_render
    init_viewports
    init_entities
    init_pointer
  end

  def init_render
    Render.set_window(self)

    images = {
      :crosshair => 'media/crosshair.png',
      :starfighter => 'media/Starfighter.bmp',
      :circle => 'media/circle.png'
    }
    Render.load_images(images)

    fonts = {
      :default => {:name => Gosu::default_font_name, :size => 30}
    }
    Render.load_fonts(fonts)
  end

  def init_viewports
    viewports = {
      :cols => 2,
      :rows => 1,
      :margin => 10.0
    }

    viewport_w = (@w - (viewports[:cols] + 1) * viewports[:margin]) / viewports[:cols]
    viewport_h = (@h - (viewports[:rows] + 1) * viewports[:margin]) / viewports[:rows]
    viewport_virtual_w = 1000

    @viewports = Array.new
    1.upto(viewports[:rows]) do |i|
      1.upto(viewports[:cols]) do |j|
        v = Viewport.new(:x => j*viewports[:margin] + (j-1) * viewport_w,
                         :y => i*viewports[:margin] + (i-1) * viewport_h,
                         :w => viewport_w,
                         :h => viewport_h,
                         :virtual_w => viewport_virtual_w,
                         :virtual_h => viewport_h * viewport_virtual_w / viewport_w,
                         :window => self)
        
        register_listener(v, :start)
        register_listener(v, :zoom_in)
        register_listener(v, :zoom_out)
        @viewports << v
      end
    end
  end

  def init_entities
    behaviors = {
      :pursuit => :evader=,
      :arrive => :target=,
      :evade => :pursuer=,
      :flee => :target=,
      :seek => :target=
    }
    
    entities =
      [
       { :entities => [{:wander => nil},
                       {:pursuit => lambda{|viewport| viewport.entities[0]}},
                       {:arrive => lambda{|viewport| viewport.mouse_pos}},
                       {:evade => lambda{|viewport| viewport.entities[0]}}]
       },
       { :entities => [{:wander => nil},
                       {:wander => nil},
                       {:wander => nil}]
       }
      ]
    
    vehicles =
      [{ :mass => 0.2,
         :max_speed => 250,
         :color => 0xffffffff},
       
       { :mass => 2.5 + lambda{rand(3)}.call,
         :max_speed => 250 + lambda{rand(100)}.call,
         :color => 0xffff6600},
       
       { :mass => 3 + lambda{rand(5)}.call,
         :max_speed => 550 + lambda{rand(50)}.call,
         :color => 0xff00ff00},
       
       { :mass => 10,
         :max_speed => 550 + lambda{rand(50)}.call,
         :color => 0xff0033ff}]
    
    entities.each_with_index do |e, i|
      e[:entities].each_with_index do |b, j|
        #v = Vehicle.create(:heavy, :pursuer)
        v = Vehicle.new(vehicles[j])
        v.pos.x = @viewports[i].virtual_w/2 + 10 * j
        v.pos.y = @viewports[i].virtual_h/2 + 10 * j
        @viewports[i].entities << v
      end
      
      @viewports[i].on(:start) do |v|
        e[:entities].each_with_index do |b, j|
          b.each_pair do |behavior, exec|
            v.entities[j].turn_on(behavior)
            if exec
              v.entities[j].send(behaviors[behavior], exec.call(v))
            end
          end
        end
      end
    end

    @viewports.each do |v|
      v.on(:zoom_in) do
        v.virtual_w /= 1.05
        v.virtual_h /= 1.05
      end
    end

    @viewports.each do |v|
      v.on(:zoom_out) do
        v.virtual_w *= 1.05
        v.virtual_h *= 1.05
      end
    end
    
  end

  def init_pointer
    set_mouse_position(@w/2, @h/2)
  end

  # Update methods
  def update
    new_time = Gosu::milliseconds
    elapsed_t = new_time - @last_time
    @last_time = new_time
    
    @fps.update(elapsed_t)
    @viewports.each do |v|
      v.update(elapsed_t)
    end
  end

  # Draw methods
  def draw
    Render.text_list do |l|
      l.list_item(@fps) if Game.debug
    end
    
    draw_pointer
    @viewports.each do |v|
      v.draw
    end
  end

  def draw_pointer
    Render.image(:crosshair,
                 :x => mouse_x,
                 :y => mouse_y,
                 :color => 0xffff0000,
                 :z_order => :pointer)
  end

  def button_down(id)
    fire(Keys[id])
    
    if id == Gosu::Button::KbEscape
      close
    end

    if id == Gosu::Button::KbD
      Game.debug = !Game.debug
    end
  end

  def register_listener(listener, event)
    @events[event] ||= Set.new
    @events[event] << listener
  end

  def fire(event)
    @events[event] && @events[event].each do |l|
      l.fire(event)
    end
  end
end

Game.new.show
