dirname = File.dirname(__FILE__)

begin
  require File.instance_eval { expand_path join(dirname, '..', 'vendor', 'gems', 'environment')}
  Bundler.require_env :test
rescue LoadError
  puts "Bundling Gems\n\nHang in there, this only has to happen once...\n\n"
  system 'gem bundle'
  retry
end

require 'rubygems'
$:.unshift File.instance_eval { expand_path join(dirname, "..", "lib") }

require 'test/unit'

class Test::Unit::TestCase
  include TestRig
  include FlexMock::TestCase
end
