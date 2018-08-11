# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.
require 'distribution'

module EvolutionSimulation
  module Evolution
    class Population
      attr_accessor :history
      attr_reader :current_members, :generation
      def initialize(size: 100, member_class: Organism, evolution_type: :both, args: {})
        @evolution_type = evolution_type
        @history = []
        @current_members = []
        @generation = 1
        @rng = Distribution::Normal.rng(0, Math.sqrt(size))
        size.times do
          current_members << (args.empty? ? member_class.new : member_class.new(args))
        end
      end

      def member_class
        best_member.class
      end

      def size
        current_members.length
      end

      def length
        current_members.length
      end

      def best_member
        current_members.max_by(&:fitness)
      end
      
      def average_fitness
        current_members.map {|c| c.fitness }.inject {|s, e| s + e }.to_f / current_members.size
      end

      def [](index)
        current_members[index]
      end

      def evolve!(times = 1)
        current_members.sort!
        times.times do
          new_gen = []
          old_gen = current_members
          parents = new_weighted_select
          parents.each do |p|
            break if new_gen.length >= old_gen.length
            parents.each do |q|
              break if new_gen.length >= old_gen.length
              child = p
              if @evolution_type == :recombine
                child = p.recombine(q)
              elsif @evolution_type == :mutate
                child = p.replicate.mutate!
              elsif @evolution_type == :both
                child = p.recombine(q).mutate!
              end
              new_gen << child
              #puts p.fitness, q.fitness, child.fitness
            end
          end 
          (old_gen.length - parents.length ** 2).times do
            break if new_gen.length >= old_gen.length
            a = parents[rand * parents.length]
            b = parents[rand * parents.length]
            child = a
            if @evolution_type == :recombine
              child = a.recombine(b)
            elsif @evolution_type == :mutate
              child = a.replicate.mutate!
            elsif @evolution_type == :both
              child = a.recombine(b).mutate!
            end
            new_gen << child
          end
          @current_members = new_gen
        end
        @generation += 1
        power = 1
        while power < @generation
          power *= 10
        end
        power /= 10
        if generation % power == 0
          @history = [history[0]] if generation == power * 10
          @history << current_members
        else
          @history.pop
          @history << current_members
        end
#        index = (@generation / power).floor * power
#        (index + 1..@generation - 2).each do |i|
#          @history[i] = nil
#        end
        current_members
      end

      private 

      def weighted_select
        goal = current_members.last.fitness + (current_members.last.fitness - current_members.first.fitness)
        sums = []
        sums[0] = [best_member.normalized_fitness(goal), best_member]
        (1..length - 1).each do |i|
          sums[i] = [sums[i - 1][0] + current_members[-(i + 1)].normalized_fitness(goal), current_members[-(i + 1)]]
        end
        sums[0][0] = 1.0
        cut = rand
        sums.select! do |s|
          s[0] > cut
        end
        parents = []
        sums.each do |s|
          parents << s[1]
        end
        parents
      end
      def new_weighted_select
        num_parents = Math.sqrt(size).floor
        parents = []
        num_parents.times do |i|
          index = @rng.call.abs.floor
          index = [index, size].min
          parents << current_members[-index - 1]
        end
        parents
      end
      def weighted_index(l)
        -((rand * rand * rand * l + 1).floor)
      end
    end
  end
end
