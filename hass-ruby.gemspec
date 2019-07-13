lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'hass-client'
  spec.version       = '0.2.0'
  spec.authors       = ['Gerrit Visscher']
  spec.email         = ['gerrit@visscher.de']
  spec.summary       = 'A small library to access Home Assistant.'
  spec.description   = 'Read and write to the HomeAssistant API. Control your smart home devices via Ruby/CLI.'
  spec.homepage      = 'https://github.com/kayssun/hass-ruby'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
end
