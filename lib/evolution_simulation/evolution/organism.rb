# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

module EvolutionSimulation
  module Evolution
    class Organism
      attr_reader :genes
      attr_accessor :name
      def initialize(name = '')
        @genes = {}
        @name = name
      end
      def mutate!
        self
      end
      def recombine(other)
        self
      end
      def fitness
        0.0
      end
      def normalized_fitness(goal)
        fitness >= goal ? Float::INFINITY : 1.0 / (goal - fitness)
      end
      def replicate
        self.dup
      end
      def <=>(other)
        return nil unless other.class == self.class
        fitness <=> other.fitness
      end
    end
  end
end
