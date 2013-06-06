# encoding: utf-8
module MindControl
  autoload :REPL,   "mind_control/repl"
  autoload :Server, "mind_control/server"
  autoload :Client, "mind_control/client"
  autoload :CUI,    "mind_control/cui"

  # Default directory for UNIX socket files.
  DEFAULT_SOCKETS_DIR = "/tmp/ruby_mind_control"

  # Global logger.
  class << self; attr_accessor :logger; end

  ##
  # Start MindControl server.
  #
  # @param [Hash] options
  #   @option options [Object] :target (TOPLEVEL_BINDING)
  #     REPL target context.
  #
  #   @option option [Hash] :pry ({})
  #     Options for Pry instance.
  #
  #   @option options [String] :name ($PROGRAM_NAME)
  #     Program name.
  #
  #   @option options [String] :sockets_dir (DEFAULT_SOCKETS_DIR)
  #     Directory where control socket will be created.
  #
  def self.start( options = {} )
    raise "MindControl already started!" if @server && @server.running?

    # Name that will be displayed in process list of mind-control client.
    # The default is process name of the host program (eg. "ruby").
    process_name = options[ :name ] || $PROGRAM_NAME

    # Make name filesystem safe
    process_name.gsub! /[^[[:alnum:]]\-_]/, "_"

    # Some shared temp directory for sockets.
    socket_dir = options[ :sockets_dir ] || DEFAULT_SOCKETS_DIR

    # Construct unique socket path for current process
    socket_name = "#{process_name}.#{Process.pid}.sock"
    socket_path = File.join( socket_dir, socket_name )

    # Construct REPL (NB: same settings for all connections!)
    repl = MindControl::REPL.new( options[ :target ] || TOPLEVEL_BINDING, options[ :pry ] || {} )

    # Start server
    @server = MindControl::Server.new( socket_path, repl )
    @server.start

    return nil
  end

  ##
  # Stop MindControl server.
  #
  def self.stop
    return unless @server

    @server.stop
    @server = nil
  end
end