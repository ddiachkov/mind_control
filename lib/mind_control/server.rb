# encoding: utf-8
require "mind_control/repl"
require "mind_control/loggable"
require "socket"
require "thread"
require "fileutils"
require "etc"

module MindControl
  ##
  # Listens UNIX socket and starts REPL sessions.
  #
  class Server
    include Loggable

    attr_reader :socket_path
    attr_reader :repl

    ##
    # @param [String] socket_path Absolute path of UNIX socket.
    # @param [#start] repl Instance of REPL (@see MindControl::REPL).
    #
    def initialize( socket_path, repl )
      @socket_path, @repl = socket_path, repl
    end

    ##
    # Start server.
    #
    def start
      return if running?

      info "Starting MindControl server on #{socket_path} ..."

      # Storage for client threads
      client_threads = ThreadGroup.new

      # Start acceptor thread
      @server_thread = Thread.new do
        begin
          start_server_loop( socket_path ) do |client_socket|
            # Process client in new thread
            client_threads.add Thread.new {
              begin
                handle_client_connection( client_socket, get_client_id( client_socket ))
              ensure
                # We MUST close the socket
                client_socket.close
              end
            }
          end
        ensure
          # Kill all client threads on server stop
          client_threads.list.each( &:kill )
        end
      end

      # We should known if our server failed
      @server_thread.abort_on_exception = true
    end

    ##
    # Stop server.
    #
    def stop
      return unless running?

      info "Stopping MindControl server ..."

      # Kill acceptor thread
      @server_thread.kill
      @server_thread.join
      @server_thread = nil
    end

    ##
    #  Server is running?
    #
    def running?
      @server_thread && @server_thread.alive?
    end

    ##
    # Starts UNIX server, accepts clients and yields its sockets in loop.
    #
    # @param [String] socket_path Path to UNIX socket to bind to.
    # @yeilds [UNIXSocket]
    #
    def start_server_loop( socket_path, &block )
      # Remove old file
      FileUtils.rm_f socket_path
      FileUtils.mkdir_p File.dirname( socket_path )

      UNIXServer.open( socket_path ) do |server|
        loop do
          # Wait for client
          block.call server.accept
        end
      end
    ensure
      # Cleanup
      FileUtils.rm socket_path
    end

    ##
    # Return id string for connected client.
    #
    # @param [UNIXSocket] socket Client socket.
    # @return [String]
    #
    def get_client_id( socket )
      # UNIX socket return effective UID/GID for connected client
      euid, _ = socket.getpeereid

      # Find record in /etc/passwd
      user_info = Etc.getpwuid euid

      return "#{user_info.name} (#{user_info.gecos})"
    end

    ##
    # Starts REPL session in separate thread for connected client.
    #
    # @param [Socket] socket Client socket.
    # @param [String] client_id ID string for connected client.
    #
    def handle_client_connection( socket, client_id )
      info "Starting new MindControl session for user #{client_id} ..."

      # Client will send us his STDIN and STDOUT
      client_stdin, client_stdout = socket.recv_io, socket.recv_io

      # Start REPL
      repl.start client_stdin, client_stdout

      info "MindControl session for user #{client_id} has ended!"
    rescue Exception => e
      error_message = "REPL exception: #{e.message} (#{e.class.name})\n#{e.backtrace.join( "\n" )}"
      error error_message

      # Send error to client
      client_stdout.puts error_message if client_stdout
    end
  end
end