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

  s.add_runtime_dependency 'nokogiri'

  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency "rake"
  s.add_development_dependency 'rspec'
  s.add_development_dependency "simplecov"
end
