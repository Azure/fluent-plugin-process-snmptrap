lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = "fluent-plugin-process-snmptrap"
  spec.version = "0.1.0"
  spec.authors = ["aj-rame3", "Gabe de la Mora"]
  spec.email   = ["ajay.ramesh@microsoft.com", "gadelamo@microsoft.com"]

  spec.description   = "A filter plugin which appends various fields to SNMP Traps received from HPE Servers"
  spec.summary       = spec.description
  spec.name   	     = "fluent-plugin-process-snmptrap"  
  spec.homepage      = "https://github.com/Azure/fluent-plugin-process-snmptrap"
  spec.license       = "MIT"

  test_files, files  = `git ls-files -z`.split("\x0").partition do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.files         = `git ls-files`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.test_files    = test_files
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "test-unit", "~> 3.0"
  spec.add_runtime_dependency "fluentd", [">= 0.14.10", "< 2"]
end
