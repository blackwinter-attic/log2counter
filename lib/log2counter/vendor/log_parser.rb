# This program parses weblogs in the NCSA Common (access log) format or
# NCSA Combined log format
#
# One line consists of
#  host rfc931 username date:time request statuscode bytes
# For example
#  1.2.3.4 - dsmith [10/Oct/1999:21:15:05 +0500] "GET /index.html HTTP/1.0" 200 12
#                   [dd/MMM/yyyy:hh:mm:ss +-hhmm]
# Where
#  dd is the day of the month
#  MMM is the month
#  yyy is the year
#  :hh is the hour
#  :mm is the minute
#  :ss is the seconds
#  +-hhmm is the time zone
#
# In practice, the day is typically logged in two-digit format even for
# single-digit days.
# For example, the second day of the month would be represented as 02.
# However, some HTTP servers do log a single digit day as a single digit.
# When parsing log records, you should be aware of both possible day
# representations.
#
# Author:: Jan Wikholm [jw@jw.fi]
# License:: MIT
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
# Modified by Jens Wille <jens.wille@uni-koeln.de>; see log_parser.rb.orig for the
# original file.

require 'logger'

class LogFormat

  attr_reader :name, :format, :format_symbols, :format_regex

  # Add more format directives here.
  DIRECTIVES = {
    # format string char => [:symbol to use, /regex to use when matching against log/]
    'h' => [:ip,           /(?:\d+\.\d+\.\d+\.\d+)|(?:[\w.-]+)/],
    'l' => [:auth,         /.*?/],
    'u' => [:username,     /.*?/],
    't' => [:datetime,     /\[.*?\]/],
    'r' => [:request,      /.*?/],
    'R' => [:request,      /.*?(:?\"|\z)/],
    's' => [:status,       /\d+/],
    'b' => [:bytecount,    /-|\d+/],
    'v' => [:domain,       /.*?/],
    'i' => [:header_lines, /.*?/],
  }

  def initialize(name, format)
    @name, @format = name, format
    parse_format(format)
  end

  # The symbols are used to map the log to the env variables.
  # The regex is used when checking what format the log is and to extract data.
  def parse_format(format)
    format_directive = /%(.*?)(\{.*?\})?([#{[DIRECTIVES.keys.join('|')]}])([\s\\"]*)/

    log_format_symbols = []
    format_regex       = ''

    format.scan(format_directive) { |condition, subdirective, directive_char, ignored|
      log_format, match_regex = process_directive(directive_char, subdirective, condition)

      ignored.gsub!(/\s/, '\\s') if ignored

      log_format_symbols << log_format
      format_regex       << "(#{match_regex})#{ignored}"
    }

    @format_symbols = log_format_symbols
    @format_regex   = /\A#{format_regex}/
  end

  def process_directive(directive_char, subdirective, condition)
    directive = DIRECTIVES[directive_char]

    case directive_char
      when 'i'
        log_format = subdirective[1...-1].downcase.tr('-', '_').to_sym
        [log_format, directive[1].source]
      else
        [directive[0], directive[1].source]
    end
  end

end

class LogParser

  LOG_FORMATS = {
    :common   => '%h %l %u %t \"%r\" %>s %b',
    :combined => '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"',
    :minimal  => '%h %l %u %t \"%R'
  }

  # Add any values that you may return here.
  STAT_ENV_MAP = {
    :ip         => 'REMOTE_ADDR',
    :page       => 'PATH_INFO',
    :datetime   => 'DATETIME',
    :status     => 'STATUS',
    :domain     => 'HTTP_HOST',
    :referer    => 'HTTP_REFERER',
    :user_agent => 'HTTP_USER_AGENT'
  }

  attr_reader :constraint, :known_formats, :log_format

  def initialize(format = nil, constraint = nil)
    @format     = format
    @constraint = constraint

    initialize_known_formats

    @log_format = known_formats[@format] if @format
  end

  # Processes the format string into symbols and test regex
  # and saves using LogFormat class.
  def initialize_known_formats
    @known_formats = {}

    LOG_FORMATS.each { |name, format|
      @known_formats[name] = LogFormat.new(name, format)
    }
  end

  # Checks which standard the log file (well one line) is.
  # Automatically checks for most complex (longest) regex first.
  def check_format(line)
    @known_formats.sort_by { |key, log_format|
      log_format.format_regex.source.size
    }.reverse.each { |key, log_format|
      return key if line.match(log_format.format_regex)
    }

    return :unknown
  end

  # This is where the magic happens.
  # This is the end-to-end business logic of the class.
  #
  # Call with a block that will be called with each line, as a hash.
  def parse_io_stream(stream)
    stats = []
    lines_parsed = 0

    stream.each { |line|
      line.chomp!
      lines_parsed += 1
      warn "##{lines_parsed}" if (lines_parsed % 10000).zero?

      next if constraint && line !~ constraint

      begin
        parsed_data = parse_line(line)
        yield generate_stats(parsed_data)
      rescue FormatError
        warn "Corrupt line [#{lines_parsed}]: #{line.inspect}"
      rescue => err
        raise err.class, "#{err.class} [#{lines_parsed}]: #{line.inspect}\n\n" <<
                         "#{parsed_data.inspect}\n\n#{err}"
      end
    }
  end

  # Populate a stats hash one line at a time.
  # Add extra fields into the STAT_ENV_MAP hash at the top of this file.
  def generate_stats(parsed_data)
    stats = { 'PATH_INFO' => get_page(parsed_data[:request]) }

    STAT_ENV_MAP.each { |stat_name, env_name|
      stats[env_name] = parsed_data[stat_name] if parsed_data.has_key?(stat_name)
    }

    stats
  end

  def get_page(request)
    (request[/\/.*?(?:\s|\z)/] || request).strip
  end

  def parse_line(line)
    unless @format && @log_format
      @format     = check_format(line)
      @log_format = known_formats[@format]

      unless log_format && line =~ log_format.format_regex
        raise FormatError, line
      end
    end

    data = line.scan(log_format.format_regex).flatten

    parsed_data = {}
    log_format.format_symbols.each_with_index { |format_symbol, index|
      parsed_data[format_symbol] = data[index]
    }

    # Remove [] from time.
    parsed_data[:datetime] &&= parsed_data[:datetime][1...-1]

    # Add IP as domain if we don't have a domain (virtual host).
    # Assumes we always have an IP.
    parsed_data[:domain] ||= parsed_data[:ip]

    parsed_data[:format] = @format

    parsed_data
  end

  class FormatError < ArgumentError; end

end
