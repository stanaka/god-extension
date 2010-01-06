module God
  module Conditions
    
    # Condition Symbol :swap_usage
    # Type: Poll
    # 
    # Trigger when the swap memory is above a specified limit.
    #
    # Paramaters
    #   Required
    #     +above+ is the amount of swap memory (in kilobytes) above which
    #             the condition should trigger. You can also use the sugar
    #             methods #kilobytes, #megabytes, and #gigabytes to clarify
    #             this amount (see examples).
    #
    # Examples
    #
    # Trigger if the process is using more than 100 megabytes of swap
    # memory(from a Watch):
    #
    #   on.condition(:swap_usage) do |c|
    #     c.above = 100.megabytes
    #   end
    #
    # Non-Watch Tasks must specify a PID file:
    #
    #   on.condition(:swap_usage) do |c|
    #     c.above = 100.megabytes
    #   end
    class SwapUsage < PollCondition
      attr_accessor :above, :times
      
      def initialize
        super
        self.above = nil
        self.times = [1, 1]
      end
      
      def prepare
        if self.times.kind_of?(Integer)
          self.times = [self.times, self.times]
        end
        
        @timeline = Timeline.new(self.times[1])
      end
      
      def reset
        @timeline.clear
      end
      
      def valid?
        valid = true
        valid &= complain("Attribute 'above' must be specified", self) if self.above.nil?
        valid
      end
      
      def test
        @timeline.push(God::System.total_swap - God::System.free_swap)
        
        history = "[" + @timeline.map { |x| "#{x > self.above ? '*' : ''}#{x}kb" }.join(", ") + "]"
        
        if @timeline.select { |x| x > self.above }.size >= self.times.first
          self.info = "swap memory out of bounds #{history}"
          return true
        else
          self.info = "swap memory within bounds #{history}"
          return false
        end
      end
    end
    
  end
end
