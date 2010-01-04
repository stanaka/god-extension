module God
  module System
  
    class ExtendedProcess < Process
      def self.fetch_system_poller
        if !@@poller.instance_of?(SlashProcExtendedPoller) && SlashProcExtendedPoller.usable?
          @@poller = SlashProcExtendedPoller
        end

        @@poller ||= if SlashProcExtendedPoller.usable?
                       SlashProcExtendedPoller
                     elsif SlashProcPoller.usable?
		       SlashProcPoller
		     else
		       PortablePoller
		     end
      end

      def group_memory
        @poller.group_memory
      end
      
      def group_cpu
        @poller.group_cpu
      end
      
      private
      
      def fetch_system_poller
        if SlashProcExtendedPoller.usable?
          SlashProcExtendedPoller
        elsif SlashProcPoller.usable?
          SlashProcPoller
        else
          PortablePoller
        end
      end
    end
  
  end
end
