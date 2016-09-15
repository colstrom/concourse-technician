Gem::Specification.new do |gem|
  gem.name        = 'concourse-technician'
  gem.version     = `git describe --tags --abbrev=0`.chomp
  gem.licenses    = 'MIT'
  gem.authors     = ['Chris Olstrom']
  gem.email       = 'chris@olstrom.com'
  gem.homepage    = 'https://github.com/colstrom/concourse-technician'
  gem.summary     = 'Troubleshoot Concourse without fly'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'btrfs', '~> 0.1', '>= 0.1.5'
  gem.add_runtime_dependency 'contracts', '~> 0.14', '>= 0.14.0'
  gem.add_runtime_dependency 'instacli', '~> 1.1', '>= 1.1.2'
  gem.add_runtime_dependency 'sequel', '~> 4.36', '>= 4.36.0'
end
