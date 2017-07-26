# encoding: utf-8
require "pry/pager"

class Pry::Pager
  alias :vanilla_best_available :best_available

  def best_available
    # If we inside mind-control session
    if _pry_ == Pry.current[ :mind_control_pry_instance ]
      # Use our custom pager
      MindControlPager.new( _pry_.input, _pry_.output )
    else
      vanilla_best_available
    end
  end

  ##
  # Custom SimplePager based pager that uses MindConrol's IO (not host).
  #
  class MindControlPager < NullPager
    ##
    # @param [IO] input console input
    # @param [IO] output console output
    #
    def initialize( input, output )
      super( output )

      @in = input
      @tracker = PageTracker.new( height - 3, width )
    end

    ##
    # Writes string to console with pagination.
    # @param [String] str
    #
    def write( str )
      str.lines.each do |line|
        @out.print line
        @tracker.record line

        if @tracker.page?
          @out.print "\n"
          @out.print "\e[0m"
          @out.print "<page break> --- Press enter to continue " \
                     "( q<enter> to break ) --- <page break>\n"

          raise StopPaging if @in.readline( "" ).chomp == "q"

          @tracker.reset
        end
      end
    end
  end
end