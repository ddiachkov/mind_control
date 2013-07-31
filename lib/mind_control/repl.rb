# encoding: utf-8
require "pry"
require "coolline"
require "mind_control/pry_monkey_patches"
require "mind_control/pry_commands"

module MindControl
  ##
  # Pry based REPL.
  #
  class REPL
    ##
    # @param [Object, Proc] target The receiver of the Pry session.
    # @param [Hash] options The optional configuration parameters for Pry.
    #
    def initialize( target, options = {} )
      @target  = target
      @options = options
    end

    ##
    # Start REPL session.
    #
    # @param [IO] stdin The object to use for input.
    # @param [IO] stdout The object to use for output.
    #
    def start( stdin, stdout )
      # NB: We cannot use Readline, because it always uses STDOUT / STDIN.
      input = CoollineAdapter.new( stdin, stdout )

      # Default command set
      commands = @options[ :commands ] || ::Pry::CommandSet.new.import( ::Pry::Commands )

      # Import our MindControl commands
      commands.import MindControl::PryCommands

      # Target can be callable
      target = @target.respond_to?( :call ) ? @target.call : @target

      # NB: input/input can't be changed via pry options!
      pry = ::Pry.new @options.merge( :commands => commands, :input => input, :output => stdout )

      # Store pry instance in thread-local context so that we can later determine
      # whether we are running inside MindControl session or not.
      ::Pry.current[ :mind_control_pry_instance ] = pry

      # Start session
      pry.repl target
    end

    ##
    # Adapter for Coolline for use with Pry.
    #
    class CoollineAdapter
      attr_reader :cool

      ##
      # @param [IO] stdin The object to use for input.
      # @param [IO] stdout The object to use for output.
      #
      def initialize( input, output )
        # Setup Coolline
        @cool = Coolline.new do |cool|
          cool.input  = input
          cool.output = output
          cool.word_boundaries = [ " ", "\t", ",", ";", '"', "'", "`", "<", ">", "=", ";", "|", "{", "}", "(", ")", "-" ]

          # By default Coolline will kill host program on Ctrl+c. Override it.
          ctrl_c_handler = cool.handlers.find { |handler| handler.char == ?\C-c }
          ctrl_c_handler.block = lambda { |instance|
            # XXX: Just close Pry
            instance.instance_variable_set "@should_exit", true
          }
        end
      end

      ##
      # Read user input with given prompt.
      #
      # @param [String] prompt
      # @return [String]
      #
      def readline( prompt )
        cool.readline prompt
      end

      ##
      # Read char from input in raw mode.#
      #
      # @return [Fixnum]
      #
      def getch
        cool.input.getch
      end

      def completion_proc=( proc )
        cool.completion_proc = proc do
          proc.call cool.completed_word
        end
      end
    end
  end
end