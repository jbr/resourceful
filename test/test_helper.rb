require 'bundler'
Bundler.require :test

$:.unshift File.expand_path("../lib", __FILE__)

require 'test/unit'

class Test::Unit::TestCase
  include TestRig
  include FlexMock::TestCase
end
