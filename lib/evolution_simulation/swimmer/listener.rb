# A custom listener allows us to get the physics engine to
# to call our code, on say contact (collisions)
module EvolutionSimulation
  module Swimmer
    class Listener
      include ContactListener

      def begin_contact(cp)
        # Get both fixtures
        f1 = cp.getFixtureA
        f2 = cp.getFixtureB
        # Get both bodies
        b1 = f1.getBody
        b2 = f2.getBody
        # Get our objects that reference these bodies
        o1 = b1.getUserData
        o2 = b2.getUserData
        if o1.is_a?(Swimmer) && o2.is_a?(Food) && !o2.eaten?
          o1.calories += o2.calories
          o2.eaten = true
        elsif o1.is_a?(Food) && !o1.eaten? && o2.is_a?(Swimmer) 
          o2.calories += o1.calories
          o1.eaten = true
        end
      end

      def end_contact(cp)
      end

      def pre_solve(_cp, _m)
      end

      def post_solve(_cp, _ci)
      end
    end
  end
end