# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

$:.push(File.expand_path(File.dirname(__FILE__)))
require 'evolution_simulation'
require 'pbox2d'

def triple_test
  pop = EvolutionSimulation::Evolution::Population.new(member_class: EvolutionSimulation::Triple::Triple)
  until pop.average_fitness >= 99 * 3
    puts "Generation: #{pop.generation}"
    puts "Best: #{pop.best_member.fitness}"
    puts "Average: #{pop.current_members.map{ |m| m.fitness }.inject { |s, e| s + e } / pop.current_members.size}"
    puts "Mutation: #{pop.best_member.mutation_chance}"
    puts
    pop.evolve!
  end
  puts "Generation: #{pop.generation}"
  puts "Best: #{pop.best_member.fitness}"
  puts "Average: #{pop.current_members.map{ |m| m.fitness }.inject { |s, e| s + e } / pop.current_members.size}"
  puts
end

def swimmer_test
  EvolutionSimulation::Swimmer::Test.new.run_sketch
end

def jumper_test
  
end

def pick_test
  puts '(T)riple, (S)wimmer, or (J)umper?'
  until ['t', 's', 'j'].include? (answer = gets.chomp.downcase)
    puts 'Try again.'
  end
  case answer
  when 't'
    triple_test
  when 's'
    swimmer_test
  when 'j'
    jumper_test
  end
end

pick_test