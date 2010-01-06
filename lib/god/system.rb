module God
  module System
    @@kb_per_page = 4 # TODO: Need to make this portable
    @@hertz = 100
    @@total_mem = nil
    @@num_of_cpu = nil
    @@uptime = nil
      
    MeminfoPath = '/proc/meminfo'
    CpuinfoPath = '/proc/cpuinfo'
    UptimePath = '/proc/uptime'
      
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

    def self.total_mem
      return @@total_mem if @@total_mem
      File.open(MeminfoPath) do |f|
        @@total_mem = f.gets.split[1].to_f
      end
    end

    def self.num_of_cpu
      return @@num_of_cpu if @@num_of_cpu

      @@num_of_cpu = File.read(CpuinfoPath).split(/\n/).grep(/^processor/).size
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
