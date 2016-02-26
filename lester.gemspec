$: << File.expand_path('../..', __FILE__)
$: << File.expand_path('../lib', __FILE__)

require 'lester/version'


Gem::Specification.new do |s|
  s.name          = 'lester'
  s.version       = Lester::VERSION
  s.authors       = ['Mathias Söderberg']
  s.email         = ['mths@sdrbrg.se']
  s.homepage      = 'https://github.com/mthssdrbrg/lester'
  s.summary       = %(Renew Let's Encrypt certificates using S3)
  s.description   = %(Let's Encrypt certificate renewer for sites hosted on S3)
  s.files         = Dir['lib/**/*.rb', 'bin/*', 'README.md']
  s.test_files    = Dir['spec/**/*']
  s.require_paths = %w[lib]
  s.bindir        = 'bin'
  s.executables   = %w[lester]
  s.license       = 'MIT'
  s.add_runtime_dependency 'json', '= 1.8.2'
  s.add_runtime_dependency 'acme-client', '~> 0.3'
  s.add_runtime_dependency 'aws-sdk', '~> 2'
  s.add_development_dependency 'rspec', '~> 3'
  s.add_development_dependency 'simplecov', '~> 0.11'
  s.add_development_dependency 'webmock', '~> 1'
  s.add_development_dependency 'vcr', '~> 3'
  s.add_development_dependency 'tara', '< 1'
  s.add_development_dependency 'github_api', '< 1'
  s.add_development_dependency 'mime-types', '~> 3'
  s.required_ruby_version = '>= 2.1'
end
