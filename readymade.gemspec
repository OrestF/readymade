# frozen_string_literal: true

require_relative 'lib/readymade/version'

Gem::Specification.new do |spec|
  spec.name          = 'readymade'
  spec.version       = Readymade::VERSION
  spec.authors       = ['OrestF']
  spec.email         = ['falchuko@gmail.com']

  spec.summary       = 'Set of base classes for ABDI architecture'
  spec.description   = 'Set of base classes for ABDI architecture'
  spec.homepage      = 'https://github.com/OrestF/readymade'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  # spec.metadata['allowed_push_host'] = 'rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.files << 'lib/readymade/model/api_attachable.rb'
  spec.files << 'lib/readymade/model/filterable.rb'
  spec.files << 'lib/readymade/controller/serialization.rb'
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'byebug', '~> 11.1', '>= 11.1.3'
  spec.add_development_dependency 'rake', '~> 13.1'
  spec.add_development_dependency 'rspec', '~> 3.13'

  spec.add_dependency 'activejob'
  spec.add_dependency 'activemodel'
end
