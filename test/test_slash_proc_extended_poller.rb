require File.dirname(__FILE__) + '/helper'
#require File.join(File.dirname(__FILE__), *%w[.. lib god])
require 'pp'
require 'god/system/slash_proc_extended_poller'

class TestSystemSlashProcExtendedPoller < Test::Unit::TestCase
  def setup
    # pid = Process.pid
    pid = 21381
    @process = System::SlashProcExtendedPoller.new(pid)
  end

  def test_stat
    pp @process.memory
    pp @process.group_memory_rough
    pp @process.group_memory
    pp @process.group_cpu
  end
  
  def test_time_string_to_seconds
    assert_equal 0, @process.bypass.time_string_to_seconds('0:00:00')
    assert_equal 0, @process.bypass.time_string_to_seconds('0:00:55')
    assert_equal 27, @process.bypass.time_string_to_seconds('0:27:32')
    assert_equal 75, @process.bypass.time_string_to_seconds('1:15:13')
    assert_equal 735, @process.bypass.time_string_to_seconds('12:15:13')
  end
end

