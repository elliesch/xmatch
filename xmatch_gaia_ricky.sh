#!/bin/sh

#ViZieR Catalog
vcat=$1
#Input data
infile=$2
#Temporary files
tmpfile=$3
#Output file
outfile=$4
#Cross-match radius in arcsec
final_radius=$5
#Location of the STILTS bash file
alias stilts=$6

tmpfile_initial=${tmpfile//.*}'_initial.fits'
tmpfile_nonull=${tmpfile//.*}'_nonull.fits'
tmpfile_newepoch=${tmpfile//.*}'_atnewepoch.fits'
initial_radius=20

#final_radius=$4
RA_CDS_COL_NAME="RA_CDS"
DEC_CDS_COL_NAME="DEC_CDS"

# match to your target list
stilts cdsskymatch cdstable=$vcat find='all' ra=RA dec=DEC in=$infile radius=20 out=$tmpfile_initial

# for dr2 change I/377 to I/345

# get rid of nulls
stilts tpipe $tmpfile_initial cmd='addcol raDR2atnewepoch "'$RA_CDS_COL_NAME'"' cmd='addcol decDR2atnewepoch "'$DEC_CDS_COL_NAME'"' cmd='replacecol pmra "NULL_pmra ? 0. : pmra" ' cmd='replacecol pmdec "NULL_pmdec ? 0. : pmdec" ' ofmt=fits out=$tmpfile_nonull

# move DR2 to input catalog epochs of coordinates given by newepoch
stilts tpipe $tmpfile_nonull cmd='replacecol raDR2atnewepoch "(((360.+((('$RA_CDS_COL_NAME'+(PMRA*(EPOCH-2015)/(3600000.*cos('$DEC_CDS_COL_NAME'*0.017453292519)))))))%360.))"' cmd='replacecol decDR2atnewepoch "((((('$DEC_CDS_COL_NAME'+(PMDEC*(EPOCH-2015.)/3600000.)))))) "' ofmt=fits out=$tmpfile_newepoch

# make a table match to itself just picking the best at the epoch of observations
stilts tmatch2 in1=$infile in2=$tmpfile_newepoch join=all1 find=best out=$outfile matcher=sky values1="RA DEC" values2="raDR2atnewepoch decDR2atnewepoch" params="$final_radius"

rm $tmpfile_initial
rm $tmpfile_nonull
rm $tmpfile_newepoch