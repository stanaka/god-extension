module God
  module Conditions
    
    # Condition Symbol :cpu_usage
    # Type: Poll
    # 
    # Trigger when the percent of CPU use of a process is above a specified limit.
    # On multi-core systems, this number could conceivably be above 100.
    #
    # Paramaters
    #   Required
    #     +pid_file+ is the pid file of the process in question. Automatically
    #                populated for Watches.
    #     +above+ is the percent CPU above which to trigger the condition. You 
    #             may use #percent to clarify this amount (see examples).
    #
    # Examples
    #
    # Trigger if the process is using more than 25 percent of the cpu (from a Watch):
    #
    #   on.condition(:cpu_usage) do |c|
    #     c.above = 25.percent
    #   end
    #
    # Non-Watch Tasks must specify a PID file:
    #
    #   on.condition(:cpu_usage) do |c|
    #     c.above = 25.percent
    #     c.pid_file = "/var/run/mongrel.3000.pid"
    #   end
    class GroupCpuUsage < CpuUsage
      def test
        process = System::ExtendedProcess.new(self.pid)
        @timeline.push(process.group_cpu)
        
        history = "[" + @timeline.map { |x| "#{x > self.above ? '*' : ''}#{x}%%" }.join(", ") + "]"
        
        if @timeline.select { |x| x > self.above }.size >= self.times.first
          self.info = "cpu out of bounds #{history}"
          return true
        else
          self.info = "cpu within bounds #{history}"
          return false
        end
      end
    end
    
  end
end
