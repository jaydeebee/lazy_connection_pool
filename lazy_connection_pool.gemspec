Gem::Specification.new { |gem|
  gem.name             = "lazy_connection_pool"
  gem.version          = "1.0.0"
  gem.platform         = Gem::Platform::RUBY
  gem.authors          = ["Joel Boutros"]
  gem.licenses         = [ 'BSD' ]

  gem.homepage         = "http://github.com/jaydeebee/lazy_connection_pool"
  gem.summary          = "A lazy connection pooler for Ruby"
  gem.description      = "A lazy connection pooler for Ruby.  Supports lazy connection allocation and dynamic pool sizing."

  gem.required_rubygems_version = ">= 1.3.6"

  gem.files            = `git ls-files`.split("\n")
  gem.executables      = []

  gem.require_path     = 'lib'
}

