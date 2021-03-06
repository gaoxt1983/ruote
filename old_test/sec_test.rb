
#
# Testing Ruote (OpenWFEru)
#
# John Mettraux at openwfe.org
#
# Tue Jan  2 13:14:37 JST 2007
#


require 'test/unit'

require 'rubygems'

%w{ lib test }.each do |path|
  path = File.expand_path(File.dirname(__FILE__) + '/../' + path)
  $:.unshift(path) unless $:.include?(path)
end

require 'openwfe/workitem'
require 'openwfe/engine/engine'


class SecTest < Test::Unit::TestCase

  def test_sec_0

    engine = OpenWFE::Engine.new

    engine.ac[:ruby_eval_allowed] = true
    engine.ac[:definition_in_launchitem_allowed] = true

    def0 = \
'''<process-definition name="" revision="0">
  <sequence>
    <!--
    <reval>puts "ok"</reval>
    <reval>self.ac[:ruby_eval_allowed] = false</reval>
    <reval>puts self.ac[:ruby_eval_allowed]</reval>
    <reval>puts "ok after"</reval>
    -->
    <reval>File.open("nada.txt") do |f| f.write("nada"); end</reval>
  </sequence>
</process-definition>'''

    dotest engine, def0

    assert(
      OpenWFE::grep(
        'exception : .:call, .:const, :File.. is excluded',
        'logs/ruote.log').size > 0)

    def2 =
'''<process-definition name="" revision="0">
  <sequence>
    <reval>
      <![CDATA[
      class << self.ac["engine"]
        def is_secure?
          true
        end
      end
      self.ac["engine"].is_secure?
      ]]>
    </reval>
  </sequence>
</process-definition>'''

    dotest(engine, def2)

    def3 =
'''<process-definition name="" revision="0">
  <sequence>
    <reval>self.ac[:ruby_eval_allowed] = false</reval>
    <reval>puts self.ac[:ruby_eval_allowed]</reval>
  </sequence>
</process-definition>'''

    dotest(engine, def3)

    assert OpenWFE::grep(
      'evaluation of ruby code is not allowed', 'logs/ruote.log')

    engine.stop
  end

  def test_sec_0b

    engine = OpenWFE::Engine.new

    engine.ac[:ruby_eval_allowed] = true
    engine.ac[:definition_in_launchitem_allowed] = true

    def1 =
'''<process-definition name="" revision="0">
  <sequence>
    <reval>
      class Object
        def my_name
          "toto"
        end
      end
      "stringobject".my_name
    </reval>
  </sequence>
</process-definition>'''

    dotest engine, def1

    assert_equal(
      2, # now and previously
      OpenWFE::grep(
        'is forbidden',
        'logs/ruote.log').size)
    #assert_equal(
    #  1,
    #  OpenWFE::grep(
    #    "Insecure: can't set constant",
    #    "logs/ruote.log").size)
      #
      # level 4 is too much (can't modify hashes)...
  end

  XMLDEF =
'''<process-definition name="" revision="0">
  <sequence>
    <set field="f" value="${ruby:5*7}" />
    <toto/>
  </sequence>
</process-definition>'''

  def test_sec_1

    value = nil

    engine = OpenWFE::Engine.new :definition_in_launchitem_allowed => true

    engine.register_participant(:toto) do |workitem|

      workitem.attributes.delete('___map_type')
        #
        # if the xmlencoder was used in previous, this field
        # might be set, removing it.

      value = "#{workitem.attributes.size}_#{workitem.f}"
    end

    engine.launch XMLDEF

    sleep 0.350

    assert_equal '2_', value

    engine.stop
  end

  def test_sec_1b

    value = nil

    engine = OpenWFE::Engine.new

    engine.register_participant(:toto) do |workitem|

      workitem.attributes.delete("___map_type")
        #
        # if the xmlencoder was used in previous, this field
        # might be set, removing it.

      value = "#{workitem.attributes.size}_#{workitem.f}"
    end

    engine.ac[:ruby_eval_allowed] = true
    engine.ac[:definition_in_launchitem_allowed] = true

    engine.launch XMLDEF

    sleep 0.350

    assert_equal '2_35', value

    engine.stop
  end

  def test_sec_2

    assert_not_nil OpenWFE::TreeChecker.new(nil, {}).check("5*7")
  end

  protected

    def dotest (engine, def_or_li)

      li = if def_or_li.is_a?(OpenWFE::LaunchItem)
        def_or_li
      else
        OpenWFE::LaunchItem.new(def_or_li)
      end

      engine.launch(li)

      sleep 0.350
    end

end

