
#
# testing Ruote
#
# since Mon Oct  9 22:19:44 JST 2006
#

dirpath = File.dirname(__FILE__)

entries = Dir.new(dirpath).entries.select { |e| e.match(/ut\_.*\.rb$/) }.sort

entries.each { |e| load "#{dirpath}/#{e}" }
