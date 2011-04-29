#--
###############################################################################
#                                                                             #
# A component of log2counter, the Apache log to COUNTER CSV converter.        #
#                                                                             #
# Copyright (C) 2007-2011 University of Cologne,                              #
#                         Albertus-Magnus-Platz,                              #
#                         50923 Cologne, Germany                              #
#                                                                             #
# Authors:                                                                    #
#     Jens Wille <jens.wille@uni-koeln.de>                                    #
#                                                                             #
# log2counter is free software; you can redistribute it and/or modify it      #
# under the terms of the GNU Affero General Public License as published by    #
# the Free Software Foundation; either version 3 of the License, or (at your  #
# option) any later version.                                                  #
#                                                                             #
# log2counter is distributed in the hope that it will be useful, but WITHOUT  #
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or       #
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License #
# for more details.                                                           #
#                                                                             #
# You should have received a copy of the GNU Affero General Public License    #
# along with log2counter. If not, see <http://www.gnu.org/licenses/>.         #
#                                                                             #
###############################################################################
#++

require 'resolv'
require 'uri'

# Get us some help for the hard part... -- um, it's not that hard, is it? ;-)
require 'log2counter/vendor/log_parser'

class Log2COUNTER::Parser

  # Map month abbreviations to their two-digit number equivalent.
  ABBR2MONTH = {}
  Date::ABBR_MONTHNAMES.each_with_index { |abbr, index|
    ABBR2MONTH[abbr] = '%02d' % index
  }

  year = Time.now.year

  # By default we will consider the current year.
  DEFAULT_MONTHS = (1..12).map { |month| '%d_%02d' % [year, month] }

  # This is what we start with -- all zero.
  DEFAULT_STATS = {
    :sessions  => 0,
    :searches  => 0,
    :downloads => 0
  }

  # NOTE: <tt>:id</tt> should contain capture group for ID
  DEFAULT_REGEXP = {
    :id       => //,
    :login    => //,
    :search   => //,
    :download => //
  }

  class << self

    def load(csv_file)
      FasterCSV.new(csv_file, :headers => true).inject({}) { |stats, row|
        month, licensee, name, address, sessions, searches, downloads = row.fields

        (((stats[month] ||= {})[licensee] ||= {})[name] ||= {})[address] = {
          :sessions  => sessions.to_i,
          :searches  => searches.to_i,
          :downloads => downloads.to_i
        }

        stats
      }
    end

  end

  attr_reader :log_file, :licensees, :months, :licensees_by_ip, :licensees_by_id, :regexp, :constraint

  def initialize(log_file, licensees, months = nil, regexp = nil)
    @log_file = log_file

    @months = months || DEFAULT_MONTHS
    raise ArgumentError, "illegal format for month; must be YYYY_MM" if @months.any? { |month|
      month !~ /\A\d\d\d\d_\d\d\z/
    }

    @regexp = DEFAULT_REGEXP.merge(regexp || {})
    @constraint = Regexp.union(*@regexp.values)

    @licensees = licensees.reject { |_, hash| !hash[:export] }
    initialize_licensees
  end

  # Now here's the method you want to call. Returns a hash:
  #
  #   stats = {
  #     '2007_06' => {
  #       'Somewhere, Inst.' => {
  #         '12.34.56.78' => {
  #           :sessions  => 12,
  #           :searches  => 34,
  #           :downloads => 56
  #         },
  #         ...
  #       },
  #       ...
  #     },
  #     ...
  #   }
  def parse
    # Cache resolved host names.
    addr2addr = Hash.new { |hash, addr|
      hash[addr] = begin
        Resolv.getaddress(addr)
      rescue Resolv::ResolvError
        addr
      end
    }

    # Cache licensees.
    addr2lcee = Hash.new { |hash, addr|
      hash[addr] = licensees_by_ip.get(addr)
    }

    # Our result hash
    stats = {}

    # Create a new LogParser and send our log file. Yields a hash per line.
    LogParser.new(:minimal, constraint).parse_io_stream(log_file) { |stat|
      path = stat['PATH_INFO']

      # Skip lines that don't have any useful information for us anyway.
      next unless path =~ constraint

      # Maybe we already captured the licensee ID? (see DEFAULT_REGEXP above)
      id = $1

      m, y  = stat['DATETIME'][/\/(.*?):/, 1].split('/')  # Extract month and year
      month = [y, ABBR2MONTH[m]].join('_')                # Target format is 'YYYY_MM'

      # Skip lines that fall out of the range we're interested in.
      next unless months.include?(month)

      address  = addr2addr[stat['REMOTE_ADDR']]
      licensee = addr2lcee[address] || licensees_by_id[
        URI.decode(id || path[regexp[:id], 1] || '')
      ]

      # Couldn't find a matching licensee? Skip it!
      next unless licensee

      name     = licensee[:name]
      licensee = licensee[:licensee]

      (((stats[month] ||= {})[licensee] ||= {})[name] ||= {})[address] ||= DEFAULT_STATS.dup
      _address = stats[month][licensee][name][address]

      # Increment our counts, since that's what we're here for...
      _address[:sessions]  += 1 if path =~ regexp[:login]
      _address[:searches]  += 1 if path =~ regexp[:search]
      _address[:downloads] += 1 if path =~ regexp[:download]
    }

    # Now we need to fill in any months and licensees we didn't come across before.
    months.each { |month|
      stats[month] ||= {}

      licensees.each { |licensee, hash|
        stats[month][licensee] ||= {}
        addresses = stats[month][licensee][hash[:name]]

        if addresses
          # Drop entries with zero sessions -- how come they occur, anyway?
          addresses.delete_if { |_, stat| stat[:sessions].zero? }
        end

        # Add a default "empty" entry for completeness' sake.
        if addresses.nil? || addresses.empty?
          stats[month][licensee][hash[:name]] = { nil => DEFAULT_STATS }
        end
      }
    }

    # That's it, return what we've got.
    stats
  end

  protected

  # Create additional mappings for our licensees.
  def initialize_licensees
    @licensees_by_ip = {}
    @licensees_by_id = {}

    licensees.each { |licensee, hash|
      _hash = { :licensee => licensee, :name => hash[:name]}

      hash[:ip].each { |ip| licensees_by_ip[ip] = _hash }
      hash[:id].each { |id| licensees_by_id[id] = _hash }
    }

    # Convenience method to get a licensee from an address. Note that
    # +licensees_by_ip+ usually has subnets instead of full IPs.
    def licensees_by_ip.get(ip)
      find(lambda { [] }) { |key, _| ip[0, key.length] == key }.last
    end
  end

end
