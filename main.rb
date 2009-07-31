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
    a = Vector2d.new(2,2)
    b = Vector2d.new(1,3)
#    puts "#{a.x}, #{a.y}, len:#{a.length}"
    c = a.add!(b)
    puts "#{c.x}, #{c.y}, len:#{c.length}"
    puts "#{a.x}, #{a.y}, len:#{a.length}"
  end

  def update
  end

  def draw
  end

  def button_down(id)
  end
end

App.new


