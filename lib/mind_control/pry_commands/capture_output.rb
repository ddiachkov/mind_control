# encoding: utf-8
require "thread"

MindControl::PryCommands.create_command "capture-output" do
  description "Captures host program STDOUT and STDERR."

  banner <<-BANNER
    Usage: capture_output [ --no-stdout | --no-stderr ] [ -f, --filter <regexp> ]

    Captures host program STDOUT and STDERR and prints it to user.
  BANNER

  command_options :shellwords => false

  def options( opt )
    opt.on :"no-stdout", "Do not capture STDOUT."
    opt.on :"no-stderr", "Do not capture STDERR."
    opt.on :f, :filter=, "Filter output with given regular expression."
  end

  def process
    raise CommandError, "You can't use --no-stdout simultaneously with --no-stderr" \
      if opts[ :"no-stdout" ] && opts[ :"no-stderr" ]

    # Line filter
    filter = opts[ :filter ] ? Regexp.new( opts[ :filter ]) : nil

    line_buffer = Hash.new

    capture_output do |kind, string|
      # Ignoring user specified outputs
      next if kind == :stdout && opts[ :"no-stdout" ]
      next if kind == :stderr && opts[ :"no-stderr" ]

      # Buffering input
      buffer  = line_buffer[ kind ] ||= ""
      buffer << string

      # Print buffered lines
      while eol = buffer.index( "\n" )
        line = buffer.slice!( 0 .. eol )

        next if filter && line !~ filter

        # Display STDERR in red
        output.write "\e[31m" if kind == :stderr
        output.write line

        # We work in raw mode and we need manually move carret to next line
        output.write "\e[0m\e[E"
      end
    end
  end

  ##
  # Capture writes to STDOUT/STDERR and yield it.
  #
  def capture_output( &block )
    output_queue = Queue.new

    # Save original write implementation
    orig_stdout_write = STDOUT.method( :write )
    orig_stderr_write = STDERR.method( :write )

    #
    # Hijack #write method and push input string to queue.
    #

    STDOUT.define_singleton_method :write do |string|
      orig_stdout_write.call( string ).tap do
        output_queue << [ :stdout, string ]
      end
    end

    STDERR.define_singleton_method :write do |string|
      orig_stderr_write.call( string ).tap do
        output_queue << [ :stderr, string ]
      end
    end

    # Separate thread to push strings to block in background.
    capture_thread = Thread.new {
      loop do
        block.call( *output_queue.pop )
      end
    }

    # Wait for Ctrl+c
    loop do
      break if _pry_.input.getch == ?\C-c
    end
  ensure
    capture_thread.kill

    # Restore original write implementation.
    STDOUT.define_singleton_method :write, orig_stdout_write
    STDERR.define_singleton_method :write, orig_stderr_write
  end
end