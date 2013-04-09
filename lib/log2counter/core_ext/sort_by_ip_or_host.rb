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

# We need strings and fixnums to be comparable.
require 'log2counter/core_ext/compare_strings_and_fixnums'

class Hash

  # Sort IP addresses numerically by net part, and host names just as usual.
  def sort_by_ip_or_host
    sort_by { |key, _|
      key ? key.split('.').map { |part|
        part =~ /\A\d+\z/ ? part.to_i : part
      } : []
    }
  end

end
