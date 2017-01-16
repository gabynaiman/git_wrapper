# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "git_wrapper/version"

Gem::Specification.new do |s|
  s.name        = 'git_wrapper'
  s.version     = GitWrapper::VERSION
  s.authors     = ['Gabriel Naiman']
  s.email       = ['gabynaiman@gmail.com']
  s.homepage    = 'https://github.com/gabynaiman/git_wrapper'
  s.summary     = 'OO git command line wrapper'
  s.description = 'OO git command line wrapper'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'nokogiri', '~> 1.6.0'

  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency "rake", '~> 10.0'
  s.add_development_dependency 'rspec', '~> 2.12.0'
  s.add_development_dependency 'simplecov', '~> 0.12'
  s.add_development_dependency 'coveralls', '~> 0.8'

  if RUBY_VERSION < '2'
    s.add_development_dependency 'tins', '~> 1.6.0'
    s.add_development_dependency 'json', '~> 1.8'
  end
end
