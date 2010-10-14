require File.instance_eval { expand_path join(dirname(__FILE__), 'test_helper') }
require 'resourceful_loader'

class BlankController < ActionController::Base
  include ResourcefulLoader
end

class LoadsFoo < BlankController
  load_resource :foo
end

class LoadsFooWithOptions < BlankController
  load_resource :foo,
                :by     => :id,
                :method => :find_by_searching,
                :only   => %w( some method names )
end

class LoadsFooWithABlock < BlankController
  load_resource :foo do |param|
    "test response #{param}"
  end
end

class LoadsFooTwice < BlankController
  load_resource :foo, :by     => :id,
                      :only   => :sometimes
  load_resource :foo, :method => :loading,
                      :except => :sometims
end

class Foo; end

class ResourcefulLoaderTest < Test::Unit::TestCase
  context "A blank AC:B" do
    should 'have a #load_resource class method' do
      assert BlankController.respond_to?(:load_resource)
    end
  end
  
  context 'With a controller that has a basic load_resource macro' do
    setup do
      @controller = LoadsFoo.new
    end

    should 'append #load_foo on the before filters' do
      assert LoadsFoo.before_filters.include?('load_foo')
    end
    
    should 'define #load_foo' do
      assert @controller.private_methods.include?("load_foo")
    end
    
    context 'on call to load_foo' do
      should 'call Foo.find_by_id(params[:foo])' do
        flexmock(@controller, :params => {'foo_id' => 'bar'})
        flexmock(Foo).should_receive(:find_by_id).once.with('bar').and_return('wibble')
        @controller.send :load_foo
        assert_equal 'wibble', @controller.instance_variable_get(:@foo)
      end
    end
  end
  
  context 'With a controller that specifies some options' do
    setup do
      @controller = LoadsFooWithOptions.new
    end
    
    should 'pass the filter options except :by and :method through to setup_filter' do
      filter = LoadsFooWithOptions.filter_chain.detect do |filter|
        filter.method == 'load_foo'
      end

      assert_options({:only => Set.new(%w(some method names))}, filter)
    end
    
    should 'call the method with params[options[:by]]' do
      flexmock @controller, :params => {:id => 'bar'}
      flexmock(Foo).should_receive(:find_by_searching).once.with('bar').and_return('wibble')
      @controller.send :load_foo
      assert_equal 'wibble', @controller.instance_variable_get(:@foo)
    end
  end
  
  context 'with a block' do
    setup { @controller = LoadsFooWithABlock.new }
    context 'load_foo' do
      should 'eval the block with params["foo_id"]' do
        flexmock @controller, :params => {'foo_id' => 'bar'}
        @controller.send :load_foo
        assert_equal 'test response bar',
                     @controller.instance_variable_get(:@foo)
      end
    end
  end


  context 'with two loads of the same resource' do
    setup { @controller = LoadsFooTwice.new }
    should 'define load_foo and load_foo_1' do
      %w(load_foo load_foo_1).each do |expected_method|
        assert LoadsFooTwice.filter_chain.detect {|filter|
          filter.method == expected_method }

        assert @controller.private_methods.include?(expected_method)
      end
    end
  end
end
