# encoding: utf-8
require "thread"

module EventMachine
  ##
  # Context for Pry.
  #
  def self.__binding__
    @binding ||= EventMachine.send( :binding ).tap do |binding|
      orig_eval = binding.method( :eval )

      ##
      # Eval code in reactor context and return result.
      #
      binding.define_singleton_method :eval do |*args, &block|
        raise "Reactor not running!" unless EventMachine.reactor_running?

        # Channel between our and reactor threads
        queue = ::Queue.new

        # In reactor context
        EventMachine::next_tick do
          # In case of fibered code we should create Fiber
          Fiber.new {
            begin
              queue.push orig_eval.call( *args, &block )
            rescue Exception => e
              # Return errors too
              queue.push e
            end
          }.resume
        end

        # Wait for result
        return queue.pop.tap do |result|
          raise result if result.is_a?( Exception )
        end
      end
    end
  end
end