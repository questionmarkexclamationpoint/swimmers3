# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

module EvolutionSimulation
  module Triple
    class Triple < Evolution::Organism
      attr_accessor :mutation_chance
      def initialize
        super
        @genes[:first] = (rand * 100).floor
        @genes[:second] = (rand * 100).floor
        @genes[:third] = (rand * 100).floor
        @mutation_chance = rand * rand * rand
      end
      def fitness
        @genes[:first] + @genes[:second] + @genes[:third]
      end
      def mutate!
        if rand < @mutation_chance
          @mutation_chance = rand * rand * rand
        end
        if rand < @mutation_chance
          r = rand
          c = (rand < 0.5 ? 1 : -1) * rand
          if r < 0.33
            if c < 0
              c *= @genes[:first]
            else
              c *= 99 - @genes[:first]
            end
            @genes[:first] += c
          elsif r < 0.66
            if c < 0
              c *= @genes[:second]
            else
              c *= 99 - @genes[:second]
            end
            @genes[:second] += c
          else
            if c < 0
              c *= @genes[:third]
            else
              c *= 99 - @genes[:third]
            end
            @genes[:third] += c
          end
        end
        self
      end
      def recombine(other)
        child = Triple.new
        child.genes[:first] = rand < 0.5 ? @genes[:first] : other.genes[:first]
        child.genes[:second] = rand < 0.5 ? @genes[:second] : other.genes[:second]
        child.genes[:third] = rand < 0.5 ? @genes[:third] : other.genes[:third]
        child.mutation_chance = rand < 0.5 ? @mutation_chance : other.mutation_chance
        child
      end
    end
  end
end