module God
  module System
    #class SlashProcExtendedPoller < SlashProcPoller
    class SlashProcExtendedPoller < PortablePoller
      @@kb_per_page = 4 # TODO: Need to make this portable
      @@hertz = 100

      @@processes = nil
      @@processes_fetch = 0
      
      # FreeBSD has /proc by default, but nothing mounted there!
      # So we should check for the actual required paths!
      # Returns true if +RequiredPaths+ are readable.
      def self.usable?
        God::System.usable?
      end
      
      def memory
        stat[:rss].to_i * @@kb_per_page
      rescue # This shouldn't fail is there's an error (or proc doesn't exist)
        0
      end
      
      def percent_memory
        (memory / God::System.total_mem.to_f) * 100
      rescue # This shouldn't fail is there's an error (or proc doesn't exist)
        0
      end

      # TODO: Change this to calculate the wma instead
      def percent_cpu
        stats = stat
        total_time = stats[:utime].to_i + stats[:stime].to_i # in jiffies
        seconds = uptime - stats[:starttime].to_i / @@hertz
        if seconds == 0
          0
        else
          ((total_time * 1000 / @@hertz) / seconds) / 10
        end
      rescue # This shouldn't fail is there's an error (or proc doesn't exist)
        0
      end

      def group_memory_rough
        mem = 0
        pg = processgroup(false)
        pg.each do |process|
          mem += process[:rss].to_i
        end
        mem * @@kb_per_page
      end

      def group_memory
        mem = 0
        pg = processgroup
        pg.each do |process|
          mem += process[:smaps][:Private_Dirty] || 0
          mem += process[:smaps][:Private_Clean] || 0
        end
        mem += pg[0][:smaps][:Shared_Dirty] || 0
        mem += pg[0][:smaps][:Shared_Clean] || 0
        mem
      end
      
      def group_cpu
        cpu = 0
        processgroup.each do |process|
          total_time = process[:utime].to_i + process[:stime].to_i # in jiffies
          seconds = uptime - process[:starttime].to_i / @@hertz
          if seconds == 0
            0
          else
            cpu += ((total_time * 1000 / @@hertz) / seconds) / 10
          end
        end
        if God::System.num_of_cpu > 1
          return cpu / God::System.num_of_cpu
        else
          return cpu
        end
      end
      
      private
      
      # Some systems (CentOS?) have a /proc, but they can hang when trying to
      # read from them. Try to use this sparingly as it is expensive.
      def self.readable?(path)
        begin
          timeout(1) { File.read(path) }
        rescue Timeout::Error
          false
        end
      end
      
      # in seconds
      def uptime
        File.read(UptimePath).split[0].to_f
      end
      
      def stat(pid = @pid)
        stats = {}
        if File.exist?("/proc/#{pid}/") && File.exist?("/proc/#{pid}/stat")
          stats[:pid], stats[:comm], stats[:state], stats[:ppid], stats[:pgrp],
          stats[:session], stats[:tty_nr], stats[:tpgid], stats[:flags],
          stats[:minflt], stats[:cminflt], stats[:majflt], stats[:cmajflt],
          stats[:utime], stats[:stime], stats[:cutime], stats[:cstime],
          stats[:priority], stats[:nice], _, stats[:itrealvalue],
          stats[:starttime], stats[:vsize], stats[:rss], stats[:rlim],
          stats[:startcode], stats[:endcode], stats[:startstack], stats[:kstkesp],
          stats[:kstkeip], stats[:signal], stats[:blocked], stats[:sigignore],
          stats[:sigcatch], stats[:wchan], stats[:nswap], stats[:cnswap],
          stats[:exit_signal], stats[:processor], stats[:rt_priority],
          stats[:policy] = File.read("/proc/#{pid}/stat").split
        end
        return stats
      rescue => e
        p 'Error:' + e.to_s + " at " + e.backtrace[0].to_s
        {}
      end

      def processgroup(check_smaps = true)
        if check_smaps && @@processes && Time.now - @@processes_fetch < 10
          return @@processes
        end
        stats = stat
        stats[:smaps] = smaps(@pid) if check_smaps
        processes = [stats]
        Dir.glob('/proc/[1-9]*') do |process|
          pid = process.match(/(\d+)$/).to_a[1]
          stats = stat(pid)
          if @pid == stats[:ppid].to_i
            stats[:smaps] = smaps(pid) if check_smaps
            processes << stats
          end
        end
        if check_smaps
          @@processes_fetch = Time.now
          @@processes = processes
        end
        processes
      end

      def smaps(pid)
        block = {}
        File.open("/proc/#{pid}/smaps") do |f|
          while(line = f.gets) do
            if line.match(/^[0-9a-f]/)
            else
              elem = line.split(/:/)
              block[elem[0].to_sym] ||= 0
              block[elem[0].to_sym] += elem[1].match(/(\d+)/).to_a[1].to_i
            end
          end
        end
        return block
      rescue => e
        p 'Error:' + e.to_s + " at " + e.backtrace[0].to_s
        {}
      end

    end
  end
end
