#--
###############################################################################
#                                                                             #
# A component of log2counter, the Apache log to COUNTER CSV converter.        #
#                                                                             #
# Copyright (C) 2007-2009 University of Cologne,                              #
#                         Albertus-Magnus-Platz,                              #
#                         50932 Cologne, Germany                              #
#                                                                             #
# Authors:                                                                    #
#     Jens Wille <jens.wille@uni-koeln.de>                                    #
#                                                                             #
# log2counter is free software; you can redistribute it and/or modify it      #
# under the terms of the GNU General Public License as published by the Free  #
# Software Foundation; either version 3 of the License, or (at your option)   #
# any later version.                                                          #
#                                                                             #
# log2counter is distributed in the hope that it will be useful, but WITHOUT  #
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or       #
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for    #
# more details.                                                               #
#                                                                             #
# You should have received a copy of the GNU General Public License along     #
# with log2counter. If not, see <http://www.gnu.org/licenses/>.               #
#                                                                             #
###############################################################################
#++

# Allow to compare strings and fixnums; the latter sorting before the other.

class String

  alias_method :_log2counter_original_cmp, :<=>

  def <=>(other)
    case other
      when Fixnum then 1  # Fixnums always sort before us.
      else             _log2counter_original_cmp(other)
    end
  end

end


class Fixnum

  alias_method :_log2counter_original_cmp, :<=>

  def <=>(other)
    case other
      when String then -1  # Strings always sort after us.
      else             _log2counter_original_cmp(other)
    end
  end

end
