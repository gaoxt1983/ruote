
#
# Testing OpenWFEru (Ruote)
#
# John Mettraux at openwfe.org
#
# Mon Oct  9 22:19:44 JST 2006
#

require 'rubygems'

require 'openwfe/def'

require File.dirname(__FILE__) + '/flowtestbase'


class FlowTest66 < Test::Unit::TestCase
  include FlowTestBase

  #
  # TEST 0

  class Test0 < OpenWFE::ProcessDefinition
    sequence do
      subproc :forget => true
      _print 'main done.'
    end
    process_definition :name => :subproc do
      sequence do
        _print 'sub done.'
      end
    end
  end

  def test_0

    #log_level_to_debug

    dotest(Test0, "main done.\nsub done.", 0.600)
  end


  #
  # TEST 1

  class Test1 < OpenWFE::ProcessDefinition
    sequence do
      subproc
      _print 'main done.'
    end
    process_definition :name => :subproc do
      sequence do
        _print 'sub done.'
      end
    end
  end

  def test_1

    #log_level_to_debug

    dotest(Test1, "sub done.\nmain done.")
  end

end

