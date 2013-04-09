require File.expand_path(%q{../lib/log2counter/version}, __FILE__)

begin
  require 'hen'

  Hen.lay! {{
    :gem => {
      :name         => %q{log2counter},
      :version      => Log2COUNTER::VERSION,
      :summary      => %q{Convert (analyse) Apache log files to COUNTER CSV.},
      :author       => %q{Jens Wille},
      :email        => %q{jens.wille@gmail.com},
      :homepage     => :blackwinter,
      :extra_files  => FileList['lib/**/vendor/*'].to_a,
      :dependencies => [['fastercsv', '>= 1.2.3']]
    }
  }}
rescue LoadError => err
  warn "Please install the `hen' gem. (#{err})"
end
