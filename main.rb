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

module ZOrder
  Viewport, Entity, UI, Pointer, Debug = *0..4
end

class App < Gosu::Window
  def initialize
    @w = 1024
    @h = 768
    @fullscreen = false
    super(@w, @h, @fullscreen)
    
    @fps = FpsCounter.new
    @last_time = Gosu::milliseconds
    
    init_render
    init_viewports
    init_entities
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
    @viewports[:game] = Viewport.new(:x => 100, :y => 100,
                                     :w => @w/2, :h => @h/2,
                                     :virtual_w => @w, :virtual_h => @h)
  end

  def init_entities
    @vehicle = Vehicle.new(:mass => 0.2, :max_speed => 150)
    @vehicle.pos.x = @viewports[:game].virtual_w/2
    @vehicle.pos.y = @viewports[:game].virtual_h/2
    
    @v2 = Vehicle.new(:mass => 1, :max_speed => 50, :color => 0xffff0000)
    @v2.pos.x = 0
    @v2.pos.y = 0

    @v3 = Vehicle.new(:mass => 0.7, :max_speed => 100, :color => 0xff00ff00)
    @v3.pos.x = 200
    @v3.pos.y = 200
    
    @viewports[:game].add_entity(@vehicle)
    @viewports[:game].add_entity(@v2)
    @viewports[:game].add_entity(@v3)
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
    @viewports[:game].update(elapsed_t)
  end

  # Draw methods
  def draw
    Render.add_list_item(@fps) if Render.debug
    Render.list(:factor => 0.7)
    draw_pointer
    @viewports[:game].draw    
  end

  def draw_pointer
    #Render.set_viewport(@viewports[:main])
    Render.image(:crosshair,
                 :x => mouse_x,
                 :y => mouse_y,
                 :color => 0xffff0000,
                 :z_order => ZOrder::Pointer)
  end

  def button_down(id)
    if id == Gosu::Button::MsLeft
      @vehicle.turn_on :arrive
      @vehicle.target = Vector2d.new(@viewports[:game].viewport_to_screen_x(mouse_x), @viewports[:game].viewport_to_screen_y(mouse_y))
      @v2.turn_on :pursuit
      @v2.evader = @vehicle

      @v3.turn_on :flee
      @v3.target = Vector2d.new(@viewports[:game].viewport_to_screen_x(mouse_x), @viewports[:game].viewport_to_screen_y(mouse_y))
    end
    
    if id == Gosu::Button::KbEscape
      close
    end

    if id == Gosu::Button::KbD
      Render.debug = !Render.debug
    end
  end
end

App.new.show
