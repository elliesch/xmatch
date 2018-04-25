import numpy as np
import os
import uuid
from astropy.io import fits
from astropy.table import Table

#Query Gaia on CDS with Ricky's STILTS code
def get_gaia(ra,dec,epochs,radius=5.0):
	
	#Assume that necessary files are in same directory as this .py code
	ricky_file = os.path.dirname(__file__)+os.sep+'xmatch_gaia_ricky.sh'
	stilts_file = os.path.dirname(__file__)+os.sep+'stilts.sh'
	
	#Catalog that will be queried
	catalog = 'I/337/gaia'#DR1
  	#catalog = 'I/345/gaia'#DR2
	
	#Create a unique ID for temporary files
	unique_id = str(uuid.uuid4())
	
	tmp_file = unique_id+'_tmp.fits'
	input_file = unique_id+'_input.fits'
	output_file = unique_id+'_output.fits'
	
	#Create an astropy table with the input data
	tdata = Table([ra,dec,epochs], names=('RA', 'DEC', 'EPOCH'))
	
	#Save to a fits file
	tdata.write(input_file)
	
	#Build the command to be launched in the terminal
	cmd = ricky_file+' "'+catalog+'" "'+input_file+'" "'+tmp_file+'" "'+output_file+'" '+str(radius)+' "'+stilts_file+'"'
	
	#Launch the cross-match with STILTS
	os.system(cmd)
	
	#If the output file cannot be found, return -1 for empty data
	if not os.path.exists(output_file):
		return -1
	
	#Read the data file into an astropy table
	outdata = Table.read(output_file,format='fits')
	
	#Remove the output file from disk
	os.remove(output_file)
	
	#Return the data to caller
	return outdata