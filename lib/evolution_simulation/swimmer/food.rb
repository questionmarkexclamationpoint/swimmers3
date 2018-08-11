module EvolutionSimulation
  module Swimmer 
    class Food
      attr_accessor :size,
                    :calories,
                    :start_position,
                    :app,
                    :body,
                    :eaten
      def initialize(
          app:,
          size: 20.0, calories: 1000.0, start_position: nil)
        @app = app
        @calories = calories
        @size = size
        start_position ||= Vec2.new(rand * (app.width - size * 3) + size, rand * (app.height - size * 3) + size)
        @start_position = start_position
        @eaten = false
      end
      def spawn!
        make_body
        self
      end
      def display
        p = app.box2d.body_coord(body)
        app.push_matrix
        app.translate(p.x, p.y)
        app.rotate(-body.angle)
        app.fill(0, 255, 0)
        app.stroke(0)
        app.ellipse(0, 0, size, size)
        app.pop_matrix
      end
      def done?
        pos = app.box2d.body_coord(body)

        return false unless pos.x.nan? || pos.y.nan? || eaten?
        kill!
        true
      end
      def kill!
        app.box2d.destroy_body(body)
        self
      end
      def eaten?
        eaten
      end
      def color
        app.color(0, 255, 0)
      end

      private

      def make_body
        bd = BodyDef.new
        bd.position = app.box2d.processing_to_world(start_position.x, start_position.y)
        bd.type = BodyType::DYNAMIC
        @body = app.box2d.create_body(bd)
        body.user_data = self
        circle = CircleShape.new
        scaled_radius = app.box2d.scale_to_world(size / 2)
        circle.m_radius = scaled_radius
        fixture = FixtureDef.new
        fixture.shape = circle
        fixture.density = 1.0
        fixture.friction = 0.01
        fixture.restitution = 0.3
        body.create_fixture(fixture)
        body
      end
    end
    end
end