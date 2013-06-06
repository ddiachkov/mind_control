# encoding: utf-8
module MindControl
  PryCommands = ::Pry::CommandSet.new
end

# Load our custom commands
Dir.glob( File.expand_path( "../pry_commands/**/*.rb", __FILE__ )).each do |file|
  require file
end