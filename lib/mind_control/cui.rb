# encoding: utf-8
require "highline"

module MindControl
  ##
  # Console User Interface.
  #
  class CUI
    attr_reader :highline

    ##
    # @param [IO] stdin (STDIN) Console input.
    # @param [IO] stdout (STDOUT) Console output.
    #
    def initialize( stdin = STDIN, stdout = STDOUT )
      @highline = ::HighLine.new( stdin, stdout )
    end

    ##
    # Ask user to select process from list.
    #
    # @param [Array<MindControl::Client::Process>] process_list
    # @return [MindControl::Client::Process]
    #
    def select_process( process_list )
      highline.choose do |menu|
        menu.header    = "Select process"
        menu.select_by = :index

        process_list.each do |process|
          menu.choice( "#{process.name} (PID: #{process.pid})" ) { process }
        end
      end
    end

    ##
    # Show debug message.
    # @param [String] message
    #
    def show_debug( message )
      highline.say HighLine::String.new( message ).white
    end

    ##
    # Show error message.
    # @param [String] message
    #
    def show_error( message )
      highline.say HighLine::String.new( message ).red
    end
  end
end