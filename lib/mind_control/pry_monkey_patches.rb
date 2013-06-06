# encoding: utf-8
require "pry/pager"

::Pry::Pager.instance_eval do
  alias :vanilla_page :page

  # Redefine standard paging method, so it will always write text to current MindControl
  # output instead of calling system pager or writing to host program $stdout.
  def self.page( text, pager = nil )
    if pry_instance = Pry.current[ :mind_control_pry_instance ]
      pry_instance.output.puts( text )
    else
      vanilla_page( text, pager )
    end
  end
end