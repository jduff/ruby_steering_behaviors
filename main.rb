# -*- coding: utf-8 -*-
dir = File.expand_path(File.dirname(__FILE__) + '/lib')
$LOAD_PATH.unshift(dir)

begin
  require 'rubygems'
rescue LoadError
end

require 'pp'

require 'render'
require 'fps'
require 'steering_behaviors'
require 'vector2d'
require 'vehicle'
require 'gosu'
require 'viewport'
require 'set'

module ZOrder
  Viewport, Entity, UI, Pointer, Debug = *0..4
end

module Keys
  @keys = {
    Gosu::Button::KbLeft => :left,
    Gosu::Button::MsLeft => :l_click,
    Gosu::Button::KbEscape => :cancel
  }

  def self.[](key)
    @keys[key]
  end
end
  

class Game < Gosu::Window
  @debug = true

  class << self
    attr_reader :debug
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
    init_events
    #init_pointer
  end

  # Init methods
  def init_render
    Render.set_window(self)
    
    @font = Gosu::Font.new(self, Gosu::default_font_name, 30)
    Render.set_font(@font)

    @graphics = Hash.new
    @graphics[:crosshair] = Gosu::Image.new(self, 'media/crosshair.png',true)
    @graphics[:starfighter] = Gosu::Image.new(self, 'media/Starfighter.bmp',true)
    Render.set_graphics(@graphics)
    
    Render.debug = true
  end

  def init_viewports
    @viewports = Hash.new
    @viewports[0] = Viewport.new(:x => 5, :y => 10,
                                 :w => 500, :h => 750,
                                 :virtual_w => 500, :virtual_h => 750,
                                 :window => self)
    
    @viewports[1] = Viewport.new(:x => 519, :y => 10,
                                 :w => 500, :h => 750,
                                 :virtual_w => 1000, :virtual_h => 1500,
                                 :window => self)
  end

  def init_entities
    @vehicle = Vehicle.new(:mass => 0.2, :max_speed => 50)
    @vehicle.pos.x = @viewports[1].virtual_w/2
    @vehicle.pos.y = @viewports[1].virtual_h/2
    
    @v2 = Vehicle.new(:mass => 1, :max_speed => 15, :color => 0xffff0000)
    @v2.pos.x = 0
    @v2.pos.y = 0

    @v3 = Vehicle.new(:mass => 0.7, :max_speed => 30, :color => 0xff00ff00)
    @v3.pos.x = 200
    @v3.pos.y = 200
    
    @viewports[1].add_entity(@vehicle)
    @viewports[1].add_entity(@v2)
    @viewports[1].add_entity(@v3)
  end

  def init_events
    register_listener(@viewports[1], :l_click)
    
    @viewports[1].on(:l_click) do
      @vehicle.turn_on :arrive
      @vehicle.target = Vector2d.new(@viewports[1].to_viewport_x(mouse_x), @viewports[1].to_viewport_y(mouse_y))
      @v2.turn_on :pursuit
      @v2.evader = @vehicle

      @v3.turn_on :flee
      @v3.target = Vector2d.new(@viewports[1].to_viewport_x(mouse_x), @viewports[1].to_viewport_y(mouse_y))
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
    @viewports.each_value do |v|
      v.update(elapsed_t)
    end
  end

  # Draw methods
  def draw
    Render.add_list_item(@fps) if Render.debug
    Render.list(:factor => 0.7)
    draw_pointer
    @viewports.each_value do |v|
      v.draw
    end
  end

  def draw_pointer
    Render.image(:crosshair,
                 :x => mouse_x,
                 :y => mouse_y,
                 :color => 0xffff0000,
                 :z_order => ZOrder::Pointer)
  end

  def button_down(id)
    fire(Keys[id])
    
    if id == Gosu::Button::KbEscape
      close
    end

    if id == Gosu::Button::KbD
      Render.debug = !Render.debug
    end

    if id == Gosu::Button::KbW
      @viewports[1].virtual_w *= 1.1
      @viewports[1].virtual_h *= 1.1
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
