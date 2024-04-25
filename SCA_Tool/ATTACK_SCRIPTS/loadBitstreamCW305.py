#Copyright (C) 2023  Amalia-Artemis Koufopoulou, Athanasios Papadimitriou , Mihalis Psarakis, David Hely

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

from chipwhisperer.capture.targets.CW305 import CW305
cw = CW305()

cw.con(bsfile=r".\ATTACK_SCRIPTS\cw305_top.bit", force=True) # Add path to your bitstream here

cw.pll
cw.pll.pll_outfreq_set(15000000, 1) # Default frequency is 15000000 Hz (15 MHz)
cw.pll.pll_outfreq_get(1)