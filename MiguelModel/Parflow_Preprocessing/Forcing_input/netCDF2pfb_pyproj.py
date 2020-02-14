#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Fri Jun  2 11:14:42 2017

@author: Miguel Aguayo

This code regrid and write WRF data into Parflow binary files. This uses the following Python modules:

- mpl_toolkit (basemap.pyproj) to reproject WRF (lon,lat) spherical coordinates to a desired cartesian coordinate system.
- SciPy (interpolate.griddata) to interpolate WRF data into the new cartesian grid.
- multiprocessing to regrid and write multiple forcing variables at the same time (Parflow.CLM needs 8 forcing variables 
per timestep and in this code we can assign one variable to one processor). 
- netCDF4 to read WRF NetCDF file format.

"""

import time
import numpy as np
from netCDF4 import Dataset
import multiprocessing as mp
import pfb_functions as pfn
from scipy.interpolate import griddata
import mpl_toolkits.basemap.pyproj as pyproj # Import the pyproj module

###############################################################################
# Define a function to convert WRF outputs into Parflow inputs
###############################################################################
 
def wrf2pfb(pfbpath,pfbname,pfbvar,ncvar,ncdata,ni,nf,ncols,nrows,mask_gcs,
            EPSG,xllcorner,yllcorner,cellsize,ncpu):
    
    print 'CPU%02d working on variable: %s...' % (ncpu,pfbvar)
    # Open WRF netCDF file
    nc = Dataset(ncdata, mode='r')
    
    # Get (lon,lat) variables
    nc_lon = nc.variables['XLONG']
    nc_lat = nc.variables['XLAT']

    # Save (lon,lat) variables as 2D array
    lon_data = nc_lon[0]
    lat_data = nc_lat[0]

    # Save (lon,lat) variables as 2D array (for mask use only)
    lon_nan = nc_lon[0]
    lat_nan = nc_lat[0]

    nc.close()
    
    # Create a mask arround domain and set values as nan
    lon_nan[(mask_gcs[3] < lon_nan) & (lon_nan < mask_gcs[1]) & (mask_gcs[2] < lat_nan) & (lat_nan < mask_gcs[0])] = np.nan

    # Get array locations for masked lon,lat
    lm = np.argwhere(np.isnan(lon_nan))
    
    # Create vectors to store lat lon and variables
    dom_size = len(lm)
    dom_lon = np.zeros(dom_size)
    dom_lat = np.zeros(dom_size)
    dom_var = np.zeros(dom_size)
    
    # Get lon,lat data from the netcdf and store them into vectors
    for i in range(dom_size):
        dom_lon[i]=lon_data[lm[i,0],lm[i,1]]
        dom_lat[i]=lat_data[lm[i,0],lm[i,1]]
    
    # Transform wrf (lon,lat) spherical coordinates to desired cartesian coordinates (CC) 
    CC = pyproj.Proj(EPSG)
    E, N = CC(dom_lon,dom_lat)
    points = np.vstack((E,N))
    tpoints = points.T
    
    # Prepare finer grid data for spatial interpolation
    lcols = ncols*cellsize
    lrows = nrows*cellsize
    xrrcorner = xllcorner+lcols
    yrrcorner = yllcorner+lrows
    xp0 = np.linspace(xllcorner,xrrcorner-cellsize,num=ncols)
    yp0 = np.linspace(yllcorner,yrrcorner-cellsize,num=nrows)
    XP, YP = np.meshgrid(xp0, yp0)

    # Create a vector to substract cumulative values of precipitation
    V0 = np.zeros(dom_size)
    
    # Get a variable from the .nc dataset and write into .pfb for each time step
    for k in range(ni,nf):
        nc = Dataset(ncdata, mode='r')
        nc_V = nc.variables[ncvar]
        V_data = nc_V[k]
        nc.close()
        
        # Get masked data from wrf variables
        for i in range(dom_size):
            dom_var[i]=V_data[lm[i,0],lm[i,1]]

        # Just for cummulative precip variable
        if pfbvar=='APCP':
            V1 = dom_var # cummulative precip
            V = (V1-V0)*2.778e-4 #substract new - old cumulative precip. and convert units to mm/s to obtain precip. rate
            V0 = V1 # store new cumulative precip
        # For any other variable
        else:
            V = dom_var
            
        # Interpolate data using LinearNDInterpolator: 
        # This consist in triangulating the input data with Qhull and then
        # each triangle performs linear barycentric interpolation)
        grid_v = griddata(tpoints, V, (XP, YP), method='linear')
        nZ = 1
        V1 = grid_v.reshape(nrows,ncols,nZ)
        
        # Prepare data to write ParFlow binary file (.pfb)
        fn = '%s%s.%s.%06d.pfb' % (pfbpath,pfbname,pfbvar,k)

        # Grid data needed for pfb
        X0 = 0; Y0 = 0; Z0 = 0
        NX = ncols; NY = nrows; NZ = nZ
        DX = cellsize; DY = cellsize; DZ = 0
        ns = 1
        # Subgrids data needed for pfb
        ix = 0; iy = 0; iz = 0
        nx = ncols; ny = nrows; nz = 1
        rx = 0; ry = 0; rz = 0
        # Writte pfb file
        pfn.write(X0,Y0,Z0,NX,NY,NZ,DX,DY,DZ,V1,ix,iy,iz,nx,ny,nz,rx,ry,rz,ns,fn)

        print '%s%s.%s.%06d ... successful created in cpu%02d!' % (pfbpath,pfbname,pfbvar,k,ncpu)
    print 'CPU%02d ...Done!' % ncpu 
#    return x,y,x1,y1,lon_data,lat_data
            

###############################################################################
# WRF and PF data meaning
###############################################################################            

# pfb file's name
# convention file name: NLDAS.<variable>.<time step>

# WRF variables in NetCDF file:

# GLW : Downward longwave flux at ground surface
# RAINNC : Accumulated total grid scale precipitation 
# SWDOWN : Downward shortwave flux at ground surface
# T2 : Air temperature at 2m
# U10 : U-component of wind at 10m
# V10 : V-component of wind at 10m
# Q2 : QV Specific humidity at 2m
# PSFC: SFC Atmospheric pressure
# XLAT : Latitude, south is negative
# XLONG : Longitude, west is negative

# ParFlow variables:

# DSWR: Downward Visible or Short-Wave radiation [W/m 2 ]
# DLWR: Downward Infa-Red or Long-Wave radiation [W/m 2 ]
# APCP: Precipitation rate [mm/s]
# Temp: Air temperature [K]
# UGRD: West-to-East or U-component of wind [m/s]
# VGRD: South-to-North or V-component of wind [m/s]
# Press: Atmospheric Pressure [pa]
# SPFH: Water-vapor specific humidity [kg/kg]

###############################################################################
# Run the code
###############################################################################

# 8 variables --> 8 cpus
ncpus = 8
    
#pfbpath = './pfbfiles/'
pfbpath = '/media/miguel/Data/WRF-Data-WY2009/python_scripts_forcing_data/1km_linear/'
pfbname = 'NLDAS'
pfbvar = ['DSWR','DLWR','APCP','Temp','UGRD','VGRD','Press','SPFH']
ncvar = ['SWDOWN','GLW','RAINNC','T2','U10','V10','PSFC','Q2']
ni = 0
nf = 10

# Raster info
ncols = 105;
nrows = 100;
xllcorner = 565500.0;
yllcorner = 4837000.0;
cellsize = 90.0;

# Select cartesian projection to be converted from spherical (lon,lat) (this case: ellipsoid WGS84 projection UTMZ11)
EPSG = '+init=EPSG:32611'

# Select reference points (corners) to create a mask arround domain
lat_urc = 43.8
lon_urc = -116.0
lat_llc = 43.65
lon_llc = -116.25

mask_gcs = [lat_urc,lon_urc,lat_llc,lon_llc]
  
## Path to netcdf files
ncdata = '/media/miguel/Selway/WRF/ID/WY2009/d03/WY_2009_d03.nc'

# Starts multithreading process
# Start time (to calculate elapsed time)
ticT = time.time()

# An array for the processes.
jobs = []
# Start ncpus processes and assign a function to each cpu.
for i in range(ncpus):
    p = mp.Process(target= wrf2pfb, args=(pfbpath,pfbname,pfbvar[i],ncvar[i],
                                          ncdata,ni,nf,ncols,nrows,mask_gcs,
                                          EPSG,xllcorner,yllcorner,cellsize,i))
    jobs.append(p)
# Start the processes	
for j in jobs:
    j.start()
# Ensure all of the processes have finished
for j in jobs:
    j.join()
    
print "All processes have finished."
# End time (to calculate elapsed time)
elapsedT = time.time()-ticT
print 'elapsed time: %f sec' % elapsedT
