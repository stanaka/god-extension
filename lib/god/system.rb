module God
  module System
    @@kb_per_page = 4 # TODO: Need to make this portable
    @@hertz = 100
    @@total_mem = nil
    @@num_of_cpu = nil
    @@uptime = nil
    @@meminfo = nil
      
    MeminfoPath = '/proc/meminfo'
    CpuinfoPath = '/proc/cpuinfo'
    UptimePath = '/proc/uptime'
    LoadAveragePath = '/proc/loadaverage'
      
    RequiredPaths = [MeminfoPath, CpuinfoPath, UptimePath]
      
    # FreeBSD has /proc by default, but nothing mounted there!
    # So we should check for the actual required paths!
    # Returns true if +RequiredPaths+ are readable.
    def self.usable?
      RequiredPaths.all? do |path|
        test(?r, path) && readable?(path)
      end
    end
      
    # in seconds
    def self.uptime
      File.read(UptimePath).split[0].to_f
    end

    # in seconds
    def self.load_average(pos = 1)
      File.read(LoadAvgragePath).split[pos].to_f
    end

    def self.total_mem
      return @@meminfo[:MemTotal] if @@meminfo
      @@meminfo = get_meminfo
      return @@meminfo[:MemTotal]
    end

    def self.num_of_cpu
      return @@num_of_cpu if @@num_of_cpu

      @@num_of_cpu = File.read(CpuinfoPath).split(/\n/).grep(/^processor/).size
    end

    def self.total_swap
      return @@meminfo[:SwapTotal] if @@meminfo
      @@meminfo = get_meminfo
      return @@meminfo[:SwapTotal]
    end

    def self.free_swap
      @@meminfo = get_meminfo
      return @@meminfo[:SwapFree]
    end


    private
    def self.get_meminfo
      block = {}
      File.open(MeminfoPath) do |f|
        while(line = f.gets) do
          elem = line.split(/:/)
          block[elem[0].to_sym] ||= 0
          block[elem[0].to_sym] += elem[1].match(/(\d+)/).to_a[1].to_i
        end
      end
      return block
    rescue => e
      p 'Error:' + e.to_s + " at " + e.backtrace
      {}
    end

    # Some systems (CentOS?) have a /proc, but they can hang when trying to
    # read from them. Try to use this sparingly as it is expensive.
    def self.readable?(path)
      begin
        timeout(1) { File.read(path) }
      rescue Timeout::Error
        false
      end
    end
      
  end
end
