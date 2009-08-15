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

module ZOrder
  Viewport, Background, Entity, UI, Pointer, Debug = *0..5
end

module Keys
  @keys = {
    Gosu::Button::KbLeft => :left,
    Gosu::Button::MsLeft => :l_click,
    Gosu::Button::KbEscape => :cancel,
    Gosu::Button::KbUp => :zoom_in,
    Gosu::Button::KbDown => :zoom_out,
    Gosu::Button::MsWheelUp => :zoom_in,
    Gosu::Button::MsWheelDown => :zoom_out
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
    @graphics[:circle] = Gosu::Image.new(self, 'media/circle.png',true)
    Render.set_graphics(@graphics)
  end

  def init_viewports
    @viewports = Array.new
    @viewports << Viewport.new(:x => 5, :y => 10,
                                 :w => 500, :h => 750,
                                 :virtual_w => 1000, :virtual_h => 1500,
                                 :window => self)
    
    @viewports << Viewport.new(:x => 519, :y => 10,
                                 :w => 500, :h => 750,
                                 :virtual_w => 1000, :virtual_h => 1500,
                                 :window => self)
  end

  def init_entities
    @viewports.each do |v|
      v1 = Vehicle.new(:mass => 2.5, :max_speed => 250 + rand(100))
      v1.pos.x = v.virtual_w/2
      v1.pos.y = v.virtual_h/2

      v2 = Vehicle.new(:mass => 3, :max_speed => 275 + rand(150), :color => 0xffff0000)
      v2.pos.x = v.virtual_w/2 - 10
      v2.pos.y = v.virtual_h/2 - 10

      v3 = Vehicle.new(:mass => 2+rand(4), :max_speed => 30+rand(200), :color => 0xff00ff00)
      v3.pos.x = v.virtual_w/2 + 10
      v3.pos.y = v.virtual_h/2 + 10

      v4 = Vehicle.new(:mass => 0.2, :max_speed => 230, :color => 0xff0cffc0)
      v4.pos.x = v.virtual_w/2 + 10
      v4.pos.y = v.virtual_h/2 + 10

      v.entities << v1
      v.entities << v2
      v.entities << v3
      v.entities << v4
    end
  end

  def init_events
    @viewports.each do |v|
      register_listener(v, :l_click)
      register_listener(v, :zoom_in)
      register_listener(v, :zoom_out)
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

    @viewports[0].on(:l_click) do |v|
      v.entities[0].turn_on :arrive
      v.entities[0].target = Vector2d.new(v.to_viewport_x(mouse_x), v.to_viewport_y(mouse_y))
      
      v.entities[1].turn_on :pursuit
      v.entities[1].evader = v.entities[3]
      
      v.entities[2].turn_on :seek
      v.entities[2].target = Vector2d.new(v.to_viewport_x(mouse_x), v.to_viewport_y(mouse_y))

      v.entities[3].turn_on :wander
    end
    
    @viewports[1].on(:l_click) do |v|
      v.entities[0].turn_on :pursuit
      v.entities[0].evader = v.entities[3]
      
      v.entities[1].turn_on :pursuit
      v.entities[1].evader = v.entities[3]
      
      v.entities[2].turn_on :seek
      v.entities[2].target = Vector2d.new(v.to_viewport_x(mouse_x), v.to_viewport_y(mouse_y))

      v.entities[3].turn_on :wander
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
                 :z_order => ZOrder::Pointer)
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
