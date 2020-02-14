#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Tue Nov 21 12:03:43 2017

@author: chaochen
"""

import numpy as np
import pylab as plt

#def asciiDEM2sa(fdem,lh):
# This function read and convert from ascii DEM to ascii SA files for Parflow
# Arguments:
# fdem: convention name for input files (e.g. DCEW_30m if the file name is DCEW_30m.dem.asc)
# lh: number of header lines to skip 

# load data from ascii DEM
fi = 'RCMEast_EPGS32611.dem.asc' 
fo = 'RCMEast_EPGS32611.dem.sa' 
    
mr = np.genfromtxt(fi,skip_header=5)
mrsize = mr.shape
mrrows = mrsize[0]
mrcols = mrsize[1]
print 'plot 1'
plt.pcolor(mr)
plt.show()
# Sort data and create ParFlow .sa
print 'plot 2'
mrflip = np.flipud(mr) # flip DEM from bottom to top
plt.pcolor(mrflip)
plt.show()
mrtran = np.transpose(mrflip) # Transpose DEM for column major sorting data
mrresh = np.reshape(mrtran,mrrows*mrcols,1)
#with file(fo, 'w') as outfile:
hdr = "%d  %d  %d" % (mrcols,mrrows,1)
np.savetxt(fo,mrresh,fmt='%f',delimiter="\n",header=hdr, comments='')
print "\033[0;32m%s file... successfully created!\033[0m" % fo 
#return mrflip




#data = np.genfromtxt('/home/chaochen/CZO/Data/Lidar/RCEastW/input_files/RCMEast_EPGS32611.soil.asc',skip_header=5)
#minval = np.min(data)
#maxval = np.max(data)
#print maxval
#print minval
#print np.unique(data)
##data = asciiDEM2sa('rcew',6)
#plt.pcolor(data,cmap='jet')
#plt.colorbar()
#plt.show()

