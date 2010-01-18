module God
  module Conditions
    
    # Condition Symbol :load_average
    # Type: Poll
    # 
    # Trigger when the load average(5min) is above a specified limit.
    #
    # Paramaters
    #   Required
    #     +above+ is the amount of load average(5min) above which
    #             the condition should trigger.
    #
    # Examples
    #
    # Trigger if the load average(5min) is above 1.0 (from a Watch):
    #
    #   on.condition(:load_average) do |c|
    #     c.above = 1.0
    #   end
    #
    class LoadAverage < PollCondition
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
        @timeline.push(God::System.load_average)
        
        history = "[" + @timeline.map { |x| "#{x > self.above ? '*' : ''}#{x}kb" }.join(", ") + "]"
        
        if @timeline.select { |x| x > self.above }.size >= self.times.first
          self.info = "load average out of bounds #{history}"
          return true
        else
          self.info = "load average within bounds #{history}"
          return false
        end
      end
    end
    
  end
end
