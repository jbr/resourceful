Gem::Specification.new do |s|
  s.name        = "resourceful_loader"
  s.version     = "0.0.3"
  s.platform    = Gem::Platform::RUBY
  s.authors     = %w( jbr )
  s.email       = %w( gems@jacobrothstein.com )
  s.homepage    = "http://github.com/jbr/resourceful_loader"
  s.summary     = "lightweight before_filter"
  s.description = "before_filter :load_foo; private def load_foo() @foo = Foo.find_by_id params[:id] end"
  s.files        = Dir.glob("lib/**/*")
  s.require_path = 'lib'
end
