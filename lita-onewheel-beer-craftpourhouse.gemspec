Gem::Specification.new do |spec|
  spec.name          = 'lita-onewheel-beer-craftpourhouse'
  spec.version       = '0.0.1'
  spec.authors       = ['Andrew Kreps']
  spec.email         = ['andrew.kreps@gmail.com']
  spec.description   = %q{Lita interface to Craftpourhouse's Barlistings.}
  spec.summary       = %q{See above.}
  spec.homepage      = 'https://github.com/onewheelskyward/lita-onewheel-beer-craftpourhouse'
  spec.license       = 'MIT'
  spec.metadata      = { 'lita_plugin_type' => 'handler' }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'lita', '~> 4'
  spec.add_runtime_dependency 'rest-client', '~> 1.8'
  spec.add_runtime_dependency 'nokogiri', '~> 1.6'
  spec.add_runtime_dependency 'sanitize', '~> 4.0'
  spec.add_runtime_dependency 'lita-onewheel-beer-base', '~> 2'

  spec.add_development_dependency 'bundler', '~> 1.3'

  # spec.add_development_dependency 'pry-byebug', '~> 3.1'
  spec.add_development_dependency 'rake', '~> 10.4'
  spec.add_development_dependency 'rack-test', '~> 0.6'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.10'
  spec.add_development_dependency 'coveralls', '~> 0.8'
end
