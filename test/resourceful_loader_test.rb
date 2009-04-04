require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require 'flexmock'
require 'resourceful_loader'

class ResourcefulController < ActionController::Base
  include ResourcefulLoader
  attr_accessor :foo
end

class Foo; end

class ResourcefulLoaderTest < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    super
    @controller = ResourcefulController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  context "with a blank ActionController::Base" do
    should 'have a #load_resource class method' do
      assert @controller.class.methods.include?('load_resource')
      assert @controller.class.respond_to?(:load_resource)
    end

    context 'with a preloaded resource foo' do
      setup do
        @controller.class.load_resource :foo
      end

      should 'have a private method #load_foo' do
        assert @controller.private_methods.include?('load_foo')
      end

      should 'append #load_foo on the before filters' do
        assert @controller.class.before_filters.include?(:load_foo)
      end

      context 'load_foo' do
        should 'call Foo.find_by_id(params[:foo])' do
          flexmock(@controller, :params => {'foo_id' => 'bar'})
          flexmock(Foo).should_receive(:find_by_id).once.with('bar').and_return('wibble')
          @controller.send :load_foo
          assert_equal 'wibble', @controller.foo
        end
      end
    end
    
    context 'with an options hash' do
      setup do
        @options = {'only' => [:some, :method, :names]}
        @controller.class.load_resource :foo, @options.merge(:by => :id, :method => :find_by_searching)
      end
      
      should 'pass the options except :by and :method through to before_filter' do
        filter = @controller.class.filter_chain.detect {|filter| filter.method == :load_foo}
        assert_equal @options, filter.options
      end
      
      should 'eval the method with params[options[:by]]' do
        flexmock(@controller, :params => {:id => 'bar'})
        flexmock(Foo).should_receive(:find_by_searching).once.with('bar').and_return('wibble')
        @controller.send :load_foo
        assert_equal 'wibble', @controller.foo
      end
    end

    context 'with a preloaded resource foo and a block' do
      setup do
        @controller.class.load_resource(:foo) do |game_id|
          "test response #{game_id}"
        end
      end

      context 'load_foo' do
        should 'eval the block with params["foo_id"]' do
          flexmock(@controller, :params => {'foo_id' => 'bar'})
          @controller.send :load_foo
          assert_equal 'test response bar', @controller.foo
        end
      end
    end
  end
end