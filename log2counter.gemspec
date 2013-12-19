# -*- encoding: utf-8 -*-
# stub: log2counter 0.0.5 ruby lib

Gem::Specification.new do |s|
  s.name = "log2counter"
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jens Wille"]
  s.date = "2013-12-19"
  s.description = "Convert (analyse) Apache log files to COUNTER CSV."
  s.email = "jens.wille@gmail.com"
  s.executables = ["log2counter"]
  s.extra_rdoc_files = ["README", "COPYING", "ChangeLog"]
  s.files = ["lib/log2counter.rb", "lib/log2counter/core_ext/compare_strings_and_fixnums.rb", "lib/log2counter/core_ext/sort_by_ip_or_host.rb", "lib/log2counter/parser.rb", "lib/log2counter/printer.rb", "lib/log2counter/vendor/log_parser.rb", "lib/log2counter/version.rb", "bin/log2counter", "lib/log2counter/vendor/log_parser.rb.orig", "COPYING", "ChangeLog", "README", "Rakefile", "example/licensees.yaml"]
  s.homepage = "http://github.com/blackwinter/log2counter"
  s.licenses = ["AGPL-3.0"]
  s.rdoc_options = ["--title", "log2counter Application documentation (v0.0.5)", "--charset", "UTF-8", "--line-numbers", "--all", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.1.11"
  s.summary = "Convert (analyse) Apache log files to COUNTER CSV."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<fastercsv>, [">= 1.2.3"])
    else
      s.add_dependency(%q<fastercsv>, [">= 1.2.3"])
    end
  else
    s.add_dependency(%q<fastercsv>, [">= 1.2.3"])
  end
end
