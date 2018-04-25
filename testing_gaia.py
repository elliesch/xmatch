import numpy as np
from astropy.table import Table
import pdb
from get_gaia import *
data = Table.read('180424@19_22_5454639142_input.fits',format='fits')
ra = np.array(data['RA'])
dec = np.array(data['DEC'])
epochs = np.array(data['EPOCH'])
test = get_gaia(ra,dec,epochs)
pdb.set_trace()