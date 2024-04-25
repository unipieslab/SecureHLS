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

import matlab.engine
from chipwhisperer.capture.targets.CW305 import CW305
eng = matlab.engine.start_matlab()
cw = CW305()

cw.con(bsfile=r".\ATTACK_SCRIPTS\cw305_top.bit", force=True) # Add path to your bitstream here - The same as loadBitstreamCW305.py

def loadKey(key):
    cw.loadEncryptionKey(key)

def loadPlaintext(pt): 
    cw.loadInput(pt)

def goCW305(): 
    cw.go()

def readCiphertext(): 
    ct = cw.readOutput()
    import scipy.io
    scipy.io.savemat('ct_mat', {'ciphertext':ct})

    #ctm = matlab.int8(ct)
    return ct