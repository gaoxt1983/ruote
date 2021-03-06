
#
# Testing Ruote
#
# John Mettraux at openwfe.org
#
# Mon Oct  9 22:19:44 JST 2006
#

require 'test/unit'

require File.dirname(__FILE__) + '/active_connection'

require 'openwfe/engine'
require 'openwfe/extras/expool/db_history'


class DbHistory0Test < Test::Unit::TestCase

  def setup

    OpenWFE::Extras::HistoryEntry.destroy_all

    @engine = OpenWFE::Engine.new :definition_in_launchitem_allowed => true

    @engine.init_service 'history', OpenWFE::Extras::DbHistory

    @engine.register_participant :alpha do
      # nothing
    end
    @engine.register_participant :bravo do
      # nothing
    end
  end

  def teardown

    @engine.stop

    #sleep 0.100
    #OpenWFE::Extras::HistoryEntry.destroy_all
  end

  def test_0

    fei = @engine.launch <<-EOS
      class TDef < OpenWFE::ProcessDefinition
        sequence do
          alpha
          sub0
        end
        define sub0 do
          bravo
        end
      end
    EOS

    @engine.wait_for(fei)

    hes = OpenWFE::Extras::HistoryEntry.find(:all)

    assert_equal 6, hes.size

    assert_equal 2, hes.select { |he| he.event == 'reply' }.size
    assert_equal 1, hes.collect { |he| he.wfid }.uniq.size

    assert_equal(
      [ nil, 'alpha', 'alpha', 'bravo', 'bravo', 'bravo' ],
      hes.collect { |he| he.participant })
  end
end

