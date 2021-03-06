# encoding: utf-8
require "mind_control"
require "socket"

module MindControl
  ##
  # MindControl client.
  #
  module Client
    extend self

    # Running process struct.
    Process = Struct.new( :name, :pid, :socket )

    ##
    # Returns running processes.
    #
    # @param [String] sockets_dir Directory with MindControl sockets.
    # @return [Array<MindControl::Client::Process>]
    #
    def get_running_processes( sockets_dir )
      processes = Dir.glob( File.join( sockets_dir, "*.sock" )).map do |file|
        name, pid = File.basename( file, ".sock" ).split( "." )
        Process.new( name, pid.to_i, file )
      end

      # Ignore not existent processes
      processes.select { |process| ::Process.kill( 0, process.pid ) rescue false }
    end

    ##
    # Connect to given process.
    # @param [MindControl::Client::Process] process Process to connect to.
    #
    def connect( process )
      UNIXSocket.open( process.socket ) do |socket|
        socket.send_io STDIN
        socket.send_io STDOUT

        # Wait for disconnect
        socket.recv( 1 )
      end
    end
  end
end