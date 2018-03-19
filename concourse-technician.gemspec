Gem::Specification.new do |gem|
  tag = `git describe --tags --abbrev=0`.chomp

  gem.name          = 'concourse-technician'
  gem.homepage      = 'https://github.com/colstrom/concourse-technician'
  gem.summary       = 'Troubleshoot Concourse without fly'

  gem.version       = "#{tag}"
  gem.licenses      = ['MIT']
  gem.authors       = ['Chris Olstrom']
  gem.email         = 'chris@olstrom.com'

  gem.cert_chain    = ['trust/certificates/colstrom.pem']
  gem.signing_key   = File.expand_path ENV.fetch 'GEM_SIGNING_KEY'

  gem.files         = `git ls-files -z`.split("\x0")
  gem.test_files    = `git ls-files -z -- {test,spec,features}/*`.split("\x0")
  gem.executables   = `git ls-files -z -- bin/*`.split("\x0").map { |f| File.basename(f) }

  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'btrfs',      '~> 0.1',  '>= 0.1.5'
  gem.add_runtime_dependency 'contracts',  '~> 0.14', '>= 0.14.0'
  gem.add_runtime_dependency 'instacli',   '~> 1.1',  '>= 1.1.2'
  gem.add_runtime_dependency 'sequel',     '~> 4.36', '>= 4.36.0'
  gem.add_runtime_dependency 'systemized', '~> 0.2',  '>= 0.2.4'
end
