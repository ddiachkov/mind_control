# Mind Control

Embeddable Pry-based REPL console for long-running ruby daemons.

Features:

- Full fledged Pry console withmcode highlighting and completion;
- Allows multiple connections;
- Executes code without interruption of the host program;
- Allows STDOUT/STDERR capturing of the host program;
- EventMachine integration;
- Has very few dependencies (no DRb / EventMachine / ZMQ);

## Installation

Add this line to your application's Gemfile:

```ruby
gem "mind_control"
```

## Requirements

- Ruby 1.9+
- *NIX operating system

## Usage

To start console server:

```ruby
require "mind_control"
MindControl.start
```

To connect to running process:

```console
$ bundle exec mind_control
```

You will be prompted with a list of running processes.

### Capture output

You can capture STDOUT/STDERR of host process. To do that execute `capture-output` in REPL.

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

MindControl can be used with EventMachine. Just set `EventMachine` as target and
all commands will be evaluated in the context of running reactor.

```ruby
require "mind_control"
require "mind_control/em"

MindControl.start :target => EventMachine
```

## TODO

- Better readme;
- Tests;
- Get rid of Engrish;