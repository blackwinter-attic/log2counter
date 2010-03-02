#--
###############################################################################
#                                                                             #
# log2counter -- Convert (analyse) Apache log files to COUNTER CSV.           #
#                                                                             #
# Copyright (C) 2007-2009 University of Cologne,                              #
#                         Albertus-Magnus-Platz,                              #
#                         50923 Cologne, Germany                              #
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

module Log2COUNTER
end

require 'log2counter/parser'
require 'log2counter/printer'

require 'log2counter/version'

module Log2COUNTER

  extend self

  def load(*args)
    Parser.load(*args)
  end

  def parse(*args)
    Parser.new(*args).parse
  end

  def print(stats, *args)
    Printer.new(*args).print(stats)
  end

end
