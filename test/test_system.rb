require File.dirname(__FILE__) + '/helper'
#require File.join(File.dirname(__FILE__), *%w[.. lib god])
require 'pp'
require 'god/system'

class TestSystem < Test::Unit::TestCase
  def setup
    # pid = Process.pid
  end

  def test_stat
    pp God::System.total_swap
    pp God::System.total_mem
    pp God::System.free_swap
  end
  
end

