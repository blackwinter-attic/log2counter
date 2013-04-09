# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{log2counter}
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jens Wille"]
  s.date = %q{2011-04-29}
  s.description = %q{Convert (analyse) Apache log files to COUNTER CSV.}
  s.email = %q{jens.wille@gmail.com}
  s.executables = ["log2counter"]
  s.extra_rdoc_files = ["README", "COPYING", "ChangeLog"]
  s.files = ["lib/log2counter/printer.rb", "lib/log2counter/version.rb", "lib/log2counter/core_ext/sort_by_ip_or_host.rb", "lib/log2counter/core_ext/compare_strings_and_fixnums.rb", "lib/log2counter/vendor/log_parser.rb", "lib/log2counter/parser.rb", "lib/log2counter.rb", "bin/log2counter", "lib/log2counter/vendor/log_parser.rb.orig", "README", "ChangeLog", "Rakefile", "COPYING", "example/licensees.yaml"]
  s.homepage = %q{http://prometheus.rubyforge.org/log2counter}
  s.rdoc_options = ["--line-numbers", "--main", "README", "--charset", "UTF-8", "--all", "--title", "log2counter Application documentation (v0.0.4)"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{prometheus}
  s.rubygems_version = %q{1.7.2}
  s.summary = %q{Convert (analyse) Apache log files to COUNTER CSV.}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<fastercsv>, [">= 1.2.3"])
    else
      s.add_dependency(%q<fastercsv>, [">= 1.2.3"])
    end
  else
    s.add_dependency(%q<fastercsv>, [">= 1.2.3"])
  end
end
