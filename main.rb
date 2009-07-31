# -*- coding: utf-8 -*-
dir = File.expand_path(File.dirname(__FILE__) + '/lib')
$LOAD_PATH.unshift(dir)

begin
  require 'rubygems'
rescue LoadError
end

require 'vector2d'
require 'vehicle'
require 'gosu'

class App < Gosu::Window
  def initialize
    super(800, 600, false)
    @v = Vehicle.new
    @old_time = Gosu::milliseconds
  end

  def update
    @time = Gosu::milliseconds
    d_time = @time - @old_time
    @old_time = @time
    @v.update(d_time)
    puts @v.to_s
  end

  def draw
  end

  def button_down(id)
  end
end

App.new.show


