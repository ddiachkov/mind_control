# Mind Control

Embeddable runtime Pry-based REPL console for long-running programs.

Features:

- Executes code without interruption of the host program;
- Full fledged Pry console with code highlighting and completion;
- Allows multiple connections;
- EventMachine integration;
- Has very few dependencies (no DRb or EventMachine);

## Installation

Add this line to your application's Gemfile:

```ruby
gem "mind_control"
```

## Requirements

- Ruby 1.9+;
- *NIX operating system (uses UNIX sockets);

## Usage

To start console server:

```ruby
require "mind_control"
MindControl.start
```

You can also set Pry target (`something.pry`):

```ruby
...
MindControl.start :target => something
```

Or Pry options:

```ruby
...
MindControl.start :pry => { .. options for pry instance .. }
```

Or set program name (see "Connection"):

```ruby
...
MindControl.start :name => "some name"
```

**NB:** HOME (or XDG_CACHE_HOME) environment variable MUST be set for host program!

### Connection

Run in terminal:

```console
$ bundle exec mind_control
```

You will be prompted with a list of currently running MindControlled processes.

Or, if you already know name or PID of process:

```console
$ bundle exec mind_control name_or_pid
```

### Capture output

You can capture STDOUT/STDERR of host program. To do that execute `capture-output` in REPL.

```text
[1] pry(main)> capture-output --help

Usage: capture_output [ --no-stdout | --no-stderr ] [ -f, --filter <regexp> ]

Captures host program STDOUT and STDERR and prints it to user.

        --no-stdout      Do not capture STDOUT.
        --no-stderr      Do not capture STDERR.
    -f, --filter         Filter output with given regular expression.
    -h, --help           Show this message.
```

### EventMachine

MindControl can be used with EventMachine. Just require file and set `EventMachine` as target and
all commands will be evaluated in the context of running reactor.

```ruby
require "mind_control"
require "mind_control/em"

MindControl.start :target => EventMachine
```

### Capistrano task

You can use capistrano to start SSH session:

```ruby
task :mind_control, :roles => :app do
  server = find_servers_for_task( current_task ).first

  exec <<-SH
    ssh #{server.user || user}@#{server.host} -p #{server.port || 22} -t "#{rvm_shell} -c 'cd #{current_path} && bundle exec mind_control'"
  SH
end
```

## TODO

- Better readme;
- Tests;
- Get rid of Engrish;