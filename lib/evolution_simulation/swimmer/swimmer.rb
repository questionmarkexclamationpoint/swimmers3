# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

module EvolutionSimulation
  module Swimmer
    Vision = Struct.new(:angle, :distance, :eyes)
    
    class Swimmer < Evolution::Organism
      attr_accessor :hue,
          :calories,
          :body,
          :calories_found,
          :app,
          :children,
          :name,
          :father,
          :mother,
          :brain,
          :size,
          :start_time,
          :start_position,
          :end_time,
          :angle,
          :genes
      extend Forwardable
      def_delegators(:@app, :max_speed, :start_calories, :max_acceleration)
      def initialize(name: random_name, metamutation_chance: 0.1, 
          app:,
          size: 10,
          start_position: nil, hue: rand, start_angle: rand * 2 * Math::PI)
        super(name)
        @app = app
        @father = nil
        @mother = nil
        @brain = nil
        @hue = hue
        @start_position = start_position ||= Vec2.new(rand * (app.width - size * 3) + size, rand * (app.height - size * 3) + size)
        @angle = start_angle
        @size = size
        @start_time = nil
        @end_time = nil
        @body = nil
        @vision = make_vision
        @brain = make_brain
        @genes = make_genes
        @calories = start_calories
      end
      def color
        s = (calories / start_calories.to_f / 5.0).clamp(0.0, 1.0)
        app.hsb_color(hue, s, 1.0)
      end
      def spawn!
        @start_time = Time.now
        make_body
        self
      end
      def fitness
        if end_time.nil?
          start_time.nil? ? 0.0 : Time.now - start_time
        else
          end_time - start_time
        end
      end
      def replicate
        self
      end
      def recombine(other)
        self
      end
      def mutate!
        self
      end
      def update!
        update_calories
        update_brain_inputs
        update_vision
        brain.think
        update_brain_outputs
        self
      end
      def display
        p = app.box2d.body_coord(body)
        app.push_matrix
        app.translate(p.x, p.y)
        app.rotate(-@angle)
        s = (calories / start_calories / 5.0).clamp(0.0, 1.0)
        app.fill(app.hsb_color(hue, s, 1.0))
        app.stroke(0)
        app.ellipse(0, 0, size, size)
        app.no_fill
        app.line(0, size, 0, -size / 2)
        a = acceleration.rotate(-@angle)
        a.x = app.box2d.scale_to_world(a.x)
        a.y = app.box2d.scale_to_world(a.y)
        app.stroke(app.color(255, 0, 0))
        app.line(0, 0, 10 * @size * a.x, 10 * @size * a.y)
        increment = @vision.angle / @vision.eyes.length.to_f
        if @vision.eyes.length > 1
          app.rotate(@vision.angle / 2.0)
        end
        @vision.eyes.each do |eye|

          if eye.hit
            app.stroke(eye.user_data.color)
            app.fill(eye.user_data.color)
            app.ellipse(0, @size / 2, @size / 4, @size / 4)
          end
          app.rotate(-increment)
        end
        app.pop_matrix
      end
      def done?
        pos = app.box2d.body_coord(body)
        # Is it off the bottom of the screen?

        return false unless pos.x.nan? || pos.y.nan? || calories <= 0 #|| pos.y > @app.box2d.height || pos.y < 0 || pos.x > @app.box2d.width || pos.x < 0
        kill!
        true
      end
      def kill!
        app.box2d.destroy_body(body)
        @body = nil
        @end_time = Time.now
        self
      end
      def acceleration
        v = Vec2.new
        v.x = max_acceleration * -(brain['right_acceleration'] - brain['left_acceleration'])
        v.y = max_acceleration * -(brain['forward_acceleration'] - brain['backward_acceleration'])
        factor = v.length_squared == 0 ? 1 : max_acceleration / v.length
        if factor < 1
          v.x *= factor
          v.y *= factor
        end
          v.y = 1.0
          v.x = 0.0
        v
      end
      def accelerate?
        true #brain['accelerate'] > 0.5
      end
      def rotation
        brain['left_rotation'] - brain['right_rotation']
      end
      def rotate?
        false #brain['rotate'] > 0.5
      end
      def speed
        Math.sqrt(body.linear_velocity.x ** 2 + body.linear_velocity.y ** 2)
      end

      private

      def make_genes
        @genes = {}
        genes
      end
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
      def make_vision
        @vision = Vision.new(Math::PI / 2, 50, [])
        5.times do
          @vision.eyes << VisionCallback.new
        end

        @vision
      end
      def make_brain
        names = []

        #input layer
        names << []

        #position
        names.last << 'left'
        names.last << 'right'
        names.last << 'up'
        names.last << 'down'

        #velocity
        names.last << 'forward_speed'
        names.last << 'backward_speed'
        names.last << 'right_speed'
        names.last << 'left_speed'

        #clock
        5.times do |i|
          names.last << "#{2 ** i}_second"
        end

        #random
        names.last << 'random'

        #hunger
        names.last << 'hunger'
        names.last << 'abundance'
        #memory
        3.times do |i|
          names.last << "memory_#{i}"
        end

        @vision.eyes.length.times do |i|
          names.last << "vision_present_#{i}"
          names.last << "vision_hue_#{i}"
          names.last << "vision_saturation_#{i}"
          names.last << "vision_brightness_#{i}"
        end
        #consider adding hearing

        #hidden layer(s)
        names << Array.new(30)

        #output layer
        names << []

        #acceleration
        names.last << 'forward_acceleration'
        names.last << 'backward_acceleration'
        names.last << 'left_acceleration'
        names.last << 'right_acceleration'
        names.last << 'accelerate'

        #rotation
        names.last << 'left_rotation'
        names.last << 'right_rotation'
        names.last << 'rotate'

        #thought
        names.last << 'thought'

        #consider adding speech, eat, reproduce
        @brain = NeuralNetwork.new(names.map(&:length))
        puts names.map(&:length)
        names.each_with_index do |n, i|
          n.each_with_index do |name, j|
            brain.name_neuron(i, j, name) unless name.nil?
          end
        end
        puts @brain.neurons.map(&:length)
        puts @brain.names
        brain
      end
      def update_vision
        d = @app.box2d.scale_to_world(@vision.distance)
        a = angle - Math::PI / 2
        if @vision.eyes.length > 1
          a -= (@vision.angle / 2.0)
        end
        increment = @vision.angle / @vision.eyes.length.to_f
        p1 = @body.position
        @vision.eyes.each_with_index do |eye, i|
          eye.reset
          p2 = Vec2.new(p1.x + d * Math.cos(a),
                        p1.y + d * Math.sin(a))
          @app.box2d.world.raycast(eye, p1, p2)
          if eye.hit
            p11 = @app.box2d.world_to_processing(p1)
            p22 = @app.box2d.world_to_processing(p2)
            app.stroke(eye.user_data.color)
            app.line(p11.x, p11.y, p22.x, p22.y)
            @brain["vision_present_#{i}"] = 1.0
            c = eye.user_data.color
            @brain["vision_hue_#{i}"] = @app.hue(c) / 255.0
            @brain["vision_saturation_#{i}"] = @app.saturation(c) / 255.0
            @brain["vision_brightness_#{i}"] = @app.brightness(c) / 255.0
          else
            @brain["vision_present_#{i}"] = 0.0
            @brain["vision_hue_#{i}"] = 0.0
            @brain["vision_saturation_#{i}"] = 0.0
            @brain["vision_brightness_#{i}"] = 0.0
          end
          a += increment
        end
      end
      def update_calories
        n = brain.neurons.map(&:length).inject(0, &:+)
        a = accelerate? ? acceleration : Vec2.new(0.0, 0.0)
        @calories -= n / 100.0 + Math.sqrt(a.x ** 2 + a.y ** 2) / max_speed + 0.1
      end
      def update_brain_inputs
        p = body.position
        c = app.box2d.body_coord(body)
        v = body.linear_velocity

        #position
        brain['left'] = (c.x. / app.width).clamp(0.0, 1.0)
        brain['right'] = ((app.width - c.x) / app.width).clamp(0.0, 1.0)
        brain['up'] = (c.y / app.height).clamp(0.0, 1.0)
        brain['down'] = ((app.height - c.y) / app.height).clamp(0.0, 1.0)

        #speed
        #rotate velocity vector to the right, so that it's relative to the front (as if the line coming straight out the front of the creature was the y axis)
        v_prime = Vec2.new(v.x * Math.cos(@angle) + v.y * Math.sin(@angle),
                           v.x * -Math.sin(@angle) + v.y * Math.cos(@angle))
        brain['forward_speed'] = (v_prime.y / max_speed).clamp(0.0, 1.0)
        brain['backward_speed'] = (-v_prime.y / max_speed).clamp(0.0, 1.0)
        brain['left_speed'] = (-v_prime.x / max_speed).clamp(0.0, 1.0)
        brain['right_speed'] = (v_prime.x / max_speed).clamp(0.0, 1.0)

        #food
        brain['hunger'] = 1.0 - (calories / start_calories).clamp(0.0, 1.0)
        brain['abundance'] = ((calories / start_calories - 1.0) / 4.0).clamp(0.0, 1.0)

        #clock
        unless start_time.nil?
          seconds = (Time.now - start_time).floor % (2 ** 5)
          5.times do |i|
            brain["#{2 ** i}_second"] = (seconds & (2 ** i)).to_f.clamp(0.0, 1.0)
          end
        end

        #memory
        2.downto(1).each do |i|
          brain["memory_#{i}"] = brain["memory_#{i - 1}"]
        end
        brain['memory_0'] = brain['thought']

        #random
        brain['random'] = rand

        #vision
      end
      def update_brain_outputs
        if accelerate?
          a = acceleration.rotate(@angle)
          v = body.linear_velocity
          body.apply_force_to_center(a) unless (v.x ** 2 + v.y ** 2 > max_speed ** 2)
        end
        if rotate?
          @angle = (@angle + rotation * Math::PI / 24) % (2 * Math::PI)
        end
      end
      def random_name
        n = ''
        @@vowels ||= ['a','e','i','o','u']
        @@consonants ||= ('a'..'z').to_a - @@vowels
        rand(4..7).times do |i|
          if @@vowels.include? n[-1]
            chance = 0.1
          else
            chance = 0.9
          end
          if rand < chance
            n += @@vowels.sample
          else
            n += @@consonants.sample
          end
        end
        n.capitalize!
      end
      def mutate_name!

      end
    end
  end
end
