#--
###############################################################################
#                                                                             #
# A component of log2counter, the Apache log to COUNTER CSV converter.        #
#                                                                             #
# Copyright (C) 2007-2012 University of Cologne,                              #
#                         Albertus-Magnus-Platz,                              #
#                         50923 Cologne, Germany                              #
#                                                                             #
# Copyright (C) 2013 Jens Wille                                               #
#                                                                             #
# Authors:                                                                    #
#     Jens Wille <jens.wille@gmail.com>                                       #
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

require 'rubygems'
require 'fastercsv'  # >= 1.2.3 for Gzip support

# We'd like to sort hashes by keys of IPs and host names.
require 'log2counter/core_ext/sort_by_ip_or_host'

class Log2COUNTER::Printer

  COLUMNS = %w[
    Jahr_Monat
    Konsortial-Mitglied
    Nutzer
    Einzelkunden-Subidentifier
    Sessions
    Searches
    Downloads
  ]

  attr_reader :csv, :summarize

  def initialize(csv_file, summarize = false)
    @csv = FasterCSV.new(csv_file)

    @summarize = summarize
  end

  def print(stats)
    # Output CSV header.
    csv << COLUMNS

    stats.sort.each { |month, licensees|
      licensees.sort.each { |licensee, names|
        names.sort.each { |name, addresses|
          if summarize
            total = Log2COUNTER::Parser::DEFAULT_STATS.dup

            addresses.each { |address, stat|
              total[:sessions]  += stat[:sessions]
              total[:searches]  += stat[:searches]
              total[:downloads] += stat[:downloads]
            }

            csv << [
              month,
              licensee,
              name,
              nil,
              total[:sessions],
              total[:searches],
              total[:downloads]
            ]
          else
            addresses.sort_by_ip_or_host.each { |address, stat|
              csv << [
                month,
                licensee,
                name,
                address,
                stat[:sessions],
                stat[:searches],
                stat[:downloads]
              ]
            }
          end
        }
      }
    }

    csv.flush
  end

end
