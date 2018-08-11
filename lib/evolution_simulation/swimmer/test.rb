# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require '/home/anna/processing-3.3.5/core/library/core.jar'
require 'pbox2d'
require 'forwardable'

java_import 'processing.core.PApplet'
java_import 'processing.core.PConstants'

module EvolutionSimulation
  module Swimmer
    class Test < PApplet
      attr_reader :box2d, :particles, :walls

      attr_accessor :max_speed, :start_calories, :max_acceleration

      def settings
        size 800, 600
      end

      def setup
        puts self.class
        @max_speed = 20.0
        @max_acceleration = 4.0
        @start_calories = 1000.0
        surface.set_title 'Collision Listening'
        @box2d = WorldBuilder.build(app: self)
        @box2d.world.setGravity(Vec2.new(0,0))

        box2d.add_listener(Listener.new)
        @swimmers = []
        @foods = []
        @walls = []
        @walls << Boundary.new(self, box2d, Vec2.new(width / 2, height - 5), Vec2.new(width, 10))
        @walls[0].bottom = true
        @walls << Boundary.new(self, box2d, Vec2.new(width / 2, 5), Vec2.new(width, 10))
        @walls << Boundary.new(self, box2d, Vec2.new(5, height / 2), Vec2.new(10, height))
        @walls << Boundary.new(self, box2d, Vec2.new(width - 5, height / 2), Vec2.new(10, height))
        @swimmers << Swimmer.new(app: self).spawn!
        @foods << Food.new(app: self).spawn!
      end

      def draw
        background(255)
        @swimmers.each do |s|
          s.update! if s.class <= Swimmer
        end
        @walls.each(&:display)
        @swimmers.each(&:display)
        @swimmers.reject!(&:done?)
        if @swimmers.empty?
          3.times do
            @swimmers << Swimmer.new(app: self).spawn!
          end
        end
        @foods.each(&:display)
        @foods.reject!(&:done?)
        if @foods.empty?
          @foods << Food.new(app: self).spawn!
        end
      end
    end
  end
end