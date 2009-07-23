# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{log2counter}
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jens Wille"]
  s.date = %q{2009-07-23}
  s.default_executable = %q{log2counter}
  s.description = %q{Convert (analyse) Apache log files to COUNTER CSV.}
  s.email = %q{jens.wille@uni-koeln.de}
  s.executables = ["log2counter"]
  s.extra_rdoc_files = ["COPYING", "ChangeLog", "README"]
  s.files = ["lib/log2counter.rb", "lib/log2counter/vendor/log_parser.rb", "lib/log2counter/printer.rb", "lib/log2counter/core_ext/compare_strings_and_fixnums.rb", "lib/log2counter/core_ext/sort_by_ip_or_host.rb", "lib/log2counter/version.rb", "lib/log2counter/parser.rb", "bin/log2counter", "Rakefile", "COPYING", "ChangeLog", "README", "sample/licensees.yaml", "lib/log2counter/vendor/log_parser.rb.orig"]
  s.homepage = %q{http://prometheus.rubyforge.org/log2counter}
  s.rdoc_options = ["--charset", "UTF-8", "--main", "README", "--line-numbers", "--inline-source", "--all", "--title", "log2counter Application documentation"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{prometheus}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Convert (analyse) Apache log files to COUNTER CSV.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<fastercsv>, [">= 1.2.3"])
    else
      s.add_dependency(%q<fastercsv>, [">= 1.2.3"])
    end
  else
    s.add_dependency(%q<fastercsv>, [">= 1.2.3"])
  end
end
