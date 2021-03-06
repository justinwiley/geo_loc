# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'geo_loc/version'

Gem::Specification.new do |spec|
  spec.name          = "geo_loc"
  spec.version       = GeoLoc::VERSION
  spec.authors       = ["Justin Wiley"]
  spec.email         = ["justin.wiley@gmail.com"]
  spec.summary       = %q{A quick-and-dirty wrapper for the GeoIP gem that handles downloading and unzipping geodata}
  spec.description   = %q{A quick-and-dirty wrapper for the GeoIP gem that handles downloading and unzipping geodata}
  spec.homepage      = ""
  spec.license       = "GPL V3"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "geoip", "~> 1.4.0"

  spec.add_development_dependency "pry"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
