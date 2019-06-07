lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ae_easy/qa/version"

Gem::Specification.new do |spec|
  spec.name          = "ae_easy-qa"
  spec.version       = AeEasy::Qa::VERSION
  spec.authors       = ["David Lynam"]
  spec.email         = ["dlynam@gmail.com"]

  spec.summary       = %q{AnswersEngine Easy Quality Assurance gem}
  spec.description   = %q{AnswersEngine Easy QA gem allows you to ensure the quality of output on Fetch}
  spec.homepage      = "https://answersengine.com"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    #spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/answersengine/ae_easy-qa"
    #spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  #spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
  #  `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  #end
  #spec.files       = ["lib/ae_easy/qa.rb"]
  spec.files = Dir.glob("{bin,lib}/**/*")
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 2.2.2'

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency 'minitest', '~> 5'
  spec.add_development_dependency "rake", "~> 10.0"
end
