# Re-usable Boundary class
module EvolutionSimulation
  module Swimmer
    class Boundary
      attr_reader :box2d, :b, :pos, :size, :a
      attr_accessor :bottom

      def initialize(
          app,
          b2d, pos, sz, a = 0)
        @app = app
        @bottom = false
        @box2d, @pos, @size, @a = b2d, pos, sz, a
        # Define the polygon
        sd = PolygonShape.new
        # Figure out the box2d coordinates
        box2d_w = box2d.scale_to_world(size.x / 2)
        box2d_h = box2d.scale_to_world(size.y / 2)
        # We're just a box
        sd.set_as_box(box2d_w, box2d_h)
        # Create the body
        bd = BodyDef.new
        bd.type = BodyType::STATIC
        bd.angle = a
        bd.position.set(box2d.processing_to_world(pos.x, pos.y))
        @b = box2d.create_body(bd)
        @b.user_data = self
        # Attached the shape to the body using a Fixture
        b.create_fixture(sd, 1)
      end

      # Draw the boundary, it doesn't move so we don't ask for location
      def display
        @app.fill(0)
        @app.stroke(0)
        @app.stroke_weight(1)
        @app.rect_mode(PConstants::CENTER)
        a = b.get_angle
        @app.push_matrix
        @app.translate(pos.x, pos.y)
        @app.rotate(-a)
        @app.rect(0, 0, size.x, size.y)
        @app.pop_matrix
      end

      def color
        0
      end
    end
  end
end