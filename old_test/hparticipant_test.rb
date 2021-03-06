
#
# Testing OpenWFEru (Ruote)
#
# John Mettraux at openwfe.org
#
# Sun Oct 29 15:41:44 JST 2006
#
# Kita Yokohama
#

require 'test/unit'

require 'rubygems'

%w{ lib }.each do |path|
  path = File.expand_path(File.dirname(__FILE__) + '/../' + path)
  $:.unshift(path) unless $:.include?(path)
end

require 'openwfe/flowexpressionid'
require 'openwfe/engine/engine'
require 'openwfe/def'
require 'openwfe/participants/store_participants'


class HParticipantTest < Test::Unit::TestCase

  def setup
    @engine = OpenWFE::Engine.new :definition_in_launchitem_allowed => true
  end

  def teardown
    @engine.stop if @engine
  end

  class HpDefinition0 < OpenWFE::ProcessDefinition
    sequence do
      participant :alice
      participant :bob
    end
  end

  def test_hp_0

    @hpAlice = OpenWFE::HashParticipant.new
    @hpBob = OpenWFE::HashParticipant.new

    @engine.register_participant :alice, @hpAlice
    @engine.register_participant :bob, @hpBob

    do_test
  end

  def test_hp_1

    #FileUtils.remove_dir "./work" if File.exist? "./work"
    FileUtils.rm_rf "work" if File.exist? "./work"

    @engine.application_context[:work_directory] = "./work"

    @hpAlice = OpenWFE::YamlParticipant.new(
      "alice", @engine.application_context)
    #@hpBob = OpenWFE::YamlParticipant.new(
    #  "bob", @engine.application_context)

    @engine.register_participant(:alice, @hpAlice)
    #@engine.register_participant(:bob, @hpBob)
    @hpBob = @engine.register_participant(:bob, OpenWFE::YamlParticipant)

    do_test
  end

  def do_test

    id = @engine.launch HpDefinition0

    assert \
      id.is_a?(OpenWFE::FlowExpressionId),
      "engine.launch() doesn't return an instance of FlowExpressionId "+
      "but of #{id.class}"

    #puts id.to_s

    #puts "alice count : #{@hpAlice.size}"
    #puts "bob count :   #{@hpBob.size}"

    sleep 0.350

    assert_equal 0, @hpBob.size
    assert_equal 1, @hpAlice.size

    wi = @hpAlice.list_workitems(id.workflow_instance_id)[0]

    assert \
      wi != nil,
      "didn't find wi for flow #{id.workflow_instance_id}"

    wi.message = "Hello bob !"

    @hpAlice.forward(wi)

    sleep 0.350

    assert_equal 0, @hpAlice.size
    assert_equal 1, @hpBob.size

    wi = @hpBob.list_workitems(id.workflow_instance_id)[0]

    assert_equal wi.message, "Hello bob !"

    @hpBob.proceed wi

    sleep 0.350

    assert_equal 0, @hpAlice.size
    assert_equal 0, @hpBob.size

    assert_equal 1, @engine.get_expression_storage.size
  end

  def test_d_0

    @hpAlice = OpenWFE::HashParticipant.new
    @hpBob = OpenWFE::HashParticipant.new

    @engine.register_participant :alice, @hpAlice
    @engine.register_participant :bob, @hpBob

    id = @engine.launch HpDefinition0

    sleep 0.350

    assert_equal 1, @hpAlice.size
    assert_equal 0, @hpBob.size

    wi = @hpAlice.first_workitem

    @hpAlice.delegate wi, @hpBob

    assert_equal 0, @hpAlice.size
    assert_equal 1, @hpBob.size

    wi = @hpBob.first_workitem

    @hpBob.proceed wi

    sleep 0.350

    assert_equal 0, @hpAlice.size
    assert_equal 1, @hpBob.size

    wi = @hpBob.first_workitem

    @hpBob.delegate wi.fei, @hpAlice

    assert_equal 1, @hpAlice.size
    assert_equal 0, @hpBob.size

    wi = @hpAlice.first_workitem

    @hpAlice.forward wi

    sleep 0.350

    assert_equal 0, @hpAlice.size
    assert_equal 0, @hpBob.size

    assert_equal 1, @engine.get_expression_storage.size
  end

end

