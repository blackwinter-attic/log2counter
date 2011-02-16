require File.expand_path(%q{../lib/log2counter/version}, __FILE__)

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
      :author       => %q{Jens Wille},
      :email        => %q{jens.wille@uni-koeln.de},
      :extra_files  => FileList['lib/**/vendor/*'].to_a,
      :dependencies => [['fastercsv', '>= 1.2.3']]
    }
  }}
rescue LoadError => err
  warn "Please install the `hen' gem. (#{err})"
end
