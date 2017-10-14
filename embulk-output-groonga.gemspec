
Gem::Specification.new do |spec|
  spec.name          = "embulk-output-groonga"
  spec.version       = "0.1.1"
  spec.authors       = ["Hiroyuki Sato"]
  spec.summary       = "Groonga output plugin for Embulk"
  spec.description   = "Dumps records to Groonga."
  spec.email         = ["hiroysato@gmail.com"]
  spec.licenses      = ["MIT"]
  spec.homepage      = "https://github.com/hiroyuki-sato/embulk-output-groonga"

  spec.files         = `git ls-files`.split("\n") + Dir["classpath/*.jar"]
  spec.test_files    = spec.files.grep(%r{^(test|spec)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'groonga-command-parser', ['>= 0.1.4']
  spec.add_dependency 'groonga-client', ['>= 0.5.2']
  spec.add_development_dependency 'bundler', ['~> 1.0']
  spec.add_development_dependency 'rake', ['>= 10.0']
end
