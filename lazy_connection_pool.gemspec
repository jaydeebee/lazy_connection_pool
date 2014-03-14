Gem::Specification.new { |gem|
  gem.name             = "lazy_connection_pool"
  gem.version          = "1.0"
  gem.platform         = Gem::Platform::RUBY
  gem.authors          = ["Joel Boutros"]

  gem.homepage         = "http://github.com/jaydeebee/lazy_connection_pool"
  gem.summary          = "A lazy connection pooler for Ruby"

  gem.required_rubygems_version = ">= 1.3.6"

  gem.files            = `git ls-files`.split("\n")
  gem.executables      = []

  gem.require_path     = 'lib'
}

