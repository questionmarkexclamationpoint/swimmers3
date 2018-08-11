module EvolutionSimulation
  module Swimmer
    class VisionCallback
      include Java::OrgJbox2dCallbacks::RayCastCallback

      attr_accessor :body, :point, :hit, :user_data

      def initialize
        @body = nil
        @hit = false
        @point = nil
        @user_data = nil
      end
      def reset
        @body = nil
        @hit = false
        @point = nil
        @user_data = nil
      end
      def report_fixture(fixture, point, normal, fraction)
        body = fixture.body
        @user_data = body.user_data
        @point = point
        @body = body
        @hit = true
        fraction
      end
      def reportFixture(fixture, point, normal, fraction)
        report_fixture(fixture, point, normal, fraction)
      end
    end
  end
end