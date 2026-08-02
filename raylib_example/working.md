The user wants to run IRB in a non-blocking way so the game keeps running. IRB's start_session is blocking by default. They'd need to either:

1. Use IRB in a thread (but stdin/stdout conflict)
2. Use a different approach like a remote debugger
3. Use IRB with a custom input method (e.g., TCP socket)

Let me think about what's practical. IRB itself doesn't have a built-in non-blocking mode. But you can:

- Use Thread.new with IRB, but the stdin/stdout will conflict with the game's rendering
- Use netcat or TCP socket to pipe into IRB from outside
- Use a proper debugger like debug gem that supports non-blocking

The most practical answer: use IRB in a background thread with a custom input source (like a socket), or use a different debugger approach.

Let me give a practical answer.
Not directly — IRB is designed to be blocking. But you have a few options:
# Option 1: IRB over a socket (piped into IRB from outside)

```ruby
# server.rb
require 'socket'
require 'irb'
require 'irb/workspace'
require 'irb/ruby-lex'

TCPServer.open('127.0.0.1', 2812) do |client|
  client.puts "IRB ready - type commands. Use 'exit' to quit."

  workspace = IRB::WorkSpace.new(binding)
  irb = IRB::Irb.new(workspace)
  irb.context.return_handler = IRB::WorkSpace::ReturnHandler.new

  ### Feed socket data into IRB's lexer
  Thread.new do
    client.each_line do |line|
      irb.context.io_stack.push(line)
      IRB::WorkSpace::ReturnHandler.run(irb.context)
    end
  end
end
```

Then from the terminal:
```bash
nc 127.0.0.1 2812
```

# Option 2: Use a non-blocking debugger gem
The debug gem (Ruby 3.0+) has a bindir approach that can work more flexibly:
require 'debug'

```ruby
# In your game loop:
if IsKeyPressed(KEY_GRAVE)
  Debug.break  # drops into debugger without killing the game thread
end
```

# Option 3: Run IRB in a thread (but you sacrifice the TTY):

```ruby
if IsKeyDown(KEY_GRAVE) && $irb_thread.nil?
  $irb_thread = Thread.new do
    IRB.start(binding)
    $irb_thread = nil
  end
end
```
The game keeps running, but you can't interact with IRB normally — your game renders to the screen and consumes stdin.
The most practical answer: Use Option 1 (socket) or a dedicated debugger. The core problem is that IRB needs exclusive control of stdin/stdout to be useful.
