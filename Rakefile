require %q{lib/log2counter/version}

begin
  require 'hen'

  Hen.lay! {{
    :rubyforge => {
      :project => %q{prometheus},
      :package => %q{log2counter}
    },

    :gem => {
      :version      => Log2COUNTER::VERSION,
      :summary      => %q{Convert (analyse) Apache log files to COUNTER CSV.},
      :files        => FileList['lib/**/*.rb', 'bin/*'].to_a,
      :extra_files  => FileList['[A-Z]*', 'sample/*', 'lib/**/vendor/*'].to_a,
      :dependencies => [['fastercsv', '>= 1.2.3']]
    }
  }}
rescue LoadError
  abort "Please install the 'hen' gem first."
end

### Place your custom Rake tasks here.
