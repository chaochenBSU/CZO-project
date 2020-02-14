# -*- coding: utf-8 -*-
"""
Created on Fri May 13 11:37:03 2016

@author: miguel
"""
import numpy as np
import struct
from sklearn.gaussian_process import GaussianProcess
from numpy import genfromtxt
import multiprocessing as mp
import time

def pfb_writer(x1,y1,z1,nx,ny,nz,dx,dy,dz,V1,ix,iy,iz,nnx,nny,nnz,rx,ry,rz,ns,fn):

   with open(fn,'wb') as fid:
        X = struct.pack('>d',x1)
        fid.write(X)
        Y = struct.pack('>d',y1)
        fid.write(Y)
        Z = struct.pack('>d',z1)
        fid.write(Z)

        NX = struct.pack('>i',nx)
        fid.write(NX)
        NY = struct.pack('>i',ny)
        fid.write(NY)
        NZ = struct.pack('>i',nz)
        fid.write(NZ)

        DX = struct.pack('>d',dx)
        fid.write(DX)
        DY = struct.pack('>d',dy)
        fid.write(DY)
        DZ = struct.pack('>d',dz)
        fid.write(DZ)

        NS = struct.pack('>i',ns)
        fid.write(NS)

        for i0 in range(ns):
            iX = struct.pack('>i',ix)
            fid.write(iX)
            iY = struct.pack('>i',iy)
            fid.write(iY)
            iZ = struct.pack('>i',iz)
            fid.write(iZ)
            nnX = struct.pack('>i',nnx)
            fid.write(nnX)
            nnY = struct.pack('>i',nny)
            fid.write(nnY)
            nnZ = struct.pack('>i',nnz)
            fid.write(nnZ)
            rX = struct.pack('>i',rx)
            fid.write(rX)
            rY = struct.pack('>i',ry)
            fid.write(rY)
            rZ = struct.pack('>i',rz)
            fid.write(rZ)

            for k in range(iz,iz+nnz):
                #print 'k = %i' %k
                for i in range(iy,iy+nny):
                    #print 'i = %i' %i
                    for j in range(ix,ix+nnx):
                        #print 'j = %i' %j
                        VAR = struct.pack('>d',V1[i,j,k])
                        fid.write(VAR)

def interpolatePSdata(clm_vars,nrows,ncols,cellsize,psdata,pspoints):

    xllcorner = 0.0
    yllcorner = 0.0
    M = np.zeros((nrows,ncols))
    M[:,:] = np.nan
    #ppdata = ppdata*0.000277778 #convert from mm/hr to mm/s
    #allocate points into matrix
    p = pspoints
    for i in range(len(psdata)):
        M[p[i,0],p[i,1]]=psdata[i]

    lcols = ncols*cellsize
    lrows = nrows*cellsize
    xrrcorner = xllcorner+lcols
    yrrcorner = yllcorner+lrows
    xp0 = np.linspace(xllcorner,xrrcorner-cellsize,num=ncols)
    yp0 = np.linspace(yllcorner,yrrcorner-cellsize,num=nrows)
    XP, YP = np.meshgrid(xp0, yp0)

    vals = ~np.isnan(M)

    #f = interpolate.Rbf(XP[vals], YP[vals], M[vals], function='linear')
    #interpolated00 = f(XP, YP)

    gp = GaussianProcess(theta0=0.1, thetaL=.001, thetaU=1., nugget=0.01)
    gp.fit(X=np.column_stack([XP[vals],YP[vals]]), y=M[vals])
    rr_cc_as_cols = np.column_stack([XP.flatten(), YP.flatten()])
    interp = gp.predict(rr_cc_as_cols).reshape(M.shape)

    if clm_vars == 'APCP':
        maxps = np.max(psdata)
        interp[interp<0.0]=0.0
        interp[interp>maxps]=maxps
    elif clm_vars == 'DSWR':
        maxps = np.max(psdata)
        interp[interp<0.0]=0.0
        interp[interp>maxps]=maxps

    return interp


def PS2Ppfb(clm_vars,psdata,pspoints,storPath_dist,storPath_aggr,st_data,years,l0,l1,l2,l3,ni,nf,
            nrows,ncols,cellsize,X0,Y0,Z0,NX,NY,NZ,DX,DY,DZ,ix,iy,iz,nx,ny,nz,rx,ry,rz,ns,nZ,distype):
               
#           for l in range(l1):
           n0 = 0
#           if clm_vars[l] == 'APCP':
           if clm_vars == 'APCP':
               print '#---------------------------------#'
               apcp_data = np.zeros((l0,l2))
               for k in range(l3): # years
                   for j in range(l2): # number of files to read
                       data = genfromtxt(('%s%s.csv' % (st_data[j],years[k])), delimiter=',',skip_header=1)
                       data[data==-6999]=np.nan
                       for i in range(ni[k]+1,nf[k]): # number of rows to read
                           n = i - ni[k] + n0
                           apcp_data[n,j] = data[i,1]-data[i-1,1] # calculates precipitation rate
                           if (apcp_data[n,j]<0.0):
                               apcp_data[n,j]=0.0
                   n0 = n

               for i in range(l0):
                   if (distype==1):
                       APCP = apcp_data[i,:]*2.778e-4  # convert units to mm/s to obtain precip. rate
                       interpolated = interpolatePSdata(clm_vars,nrows,ncols,cellsize,APCP,pspoints)
                       # interpolate point scale data
                       rint = interpolated.flatten()
                       intresh = rint.reshape(nrows,ncols,nZ)
                       vn = 'NLDAS.APCP'
                       fn = '%s/%s.%06d.pfb' % (storPath_dist,vn,i)
                       # writte pfb file
                       pfb_writer(X0,Y0,Z0,NX,NY,NZ,DX,DY,DZ,intresh,ix,iy,iz,nx,ny,nz,rx,ry,rz,ns,fn)
                       print 'Fully distributed %s.%06d.pfb: created' % (vn,i)
                   elif (distype==2):
                       APCP = np.nanmean(apcp_data[i,:])*2.778e-4
                       APCP_data2D = pfbdata2D + APCP
                       vn = 'NLDAS.APCP'
                       fn = '%s/%s.%06d.pfb' % (storPath_aggr,vn,i)
                       # writte pfb file
                       pfb_writer(X0,Y0,Z0,NX,NY,NZ,DX,DY,DZ,APCP_data2D,ix,iy,iz,nx,ny,nz,rx,ry,rz,ns,fn)
                       print 'Aggregated %s.%06d.pfb: created' % (vn,i)
                       
           elif clm_vars == 'Temp':
                 print '#---------------------------------#'
                 Temp_data = np.zeros((l0,l2))
                 for k in range(l3): # years
                     for j in range(l2): # number of files to read
                         data = genfromtxt(('%s%s.csv' % (st_data[j],years[k])), delimiter=',',skip_header=1)
                         data[data==-6999]=np.nan
                         for i in range(ni[k],nf[k]): # number of rows to read
                             n = i - ni[k] + n0
                             Temp_data[n,j] = data[i,2] + 273.16
                     n0 = n

                 for i in range(l0):
                     if (distype==1):
                         Temp = Temp_data[i,:]
                         # interpolate point scale data
                         interpolated = interpolatePSdata(clm_vars,nrows,ncols,cellsize,Temp,pspoints)
                         rint = interpolated.flatten()
                         intresh = rint.reshape(nrows,ncols,nZ)
                         vn = 'NLDAS.Temp'
                         fn = '%s/%s.%06d.pfb' % (storPath_dist,vn,i)
                         # writte pfb file
                         pfb_writer(X0,Y0,Z0,NX,NY,NZ,DX,DY,DZ,intresh,ix,iy,iz,nx,ny,nz,rx,ry,rz,ns,fn)
                         print 'Fully distributed %s.%06d.pfb: created' % (vn,i)
                     elif (distype==2):
                         Temp = np.nanmean(Temp_data[i,:])
                         Temp_data2D = pfbdata2D + Temp
                         vn = 'NLDAS.Temp'
                         fn = '%s/%s.%06d.pfb' % (storPath_aggr,vn,i)
                         # writte pfb file
                         pfb_writer(X0,Y0,Z0,NX,NY,NZ,DX,DY,DZ,Temp_data2D,ix,iy,iz,nx,ny,nz,rx,ry,rz,ns,fn)
                         print 'Aggregated %s.%06d.pfb: created' % (vn,i)
#                       
           elif clm_vars == 'DSWR':
                 print '#---------------------------------#'
                 dswr_data = np.zeros((l0,l2))
                 for k in range(l3): # years
                     for j in range(l2): # number of files to read
                         data = genfromtxt(('%s%s.csv' % (st_data[j],years[k])), delimiter=',',skip_header=1)
                         data[data==-6999]=np.nan
                         for i in range(ni[k],nf[k]): # number of rows to read
                             n = i - ni[k] + n0
                             dswr_data[n,j] = data[i,3]
                             #                    print n
                     n0 = n
                    
                 for i in range(l0):
                     if (distype==1):
                         DSWR = dswr_data[i,:]
                         # interpolate point scale data
                         interpolated = interpolatePSdata(clm_vars,nrows,ncols,cellsize,DSWR,pspoints)
                         rint = interpolated.flatten()
                         intresh = rint.reshape(nrows,ncols,nZ)
                         vn = 'NLDAS.DSWR'
                         fn = '%s/%s.%06d.pfb' % (storPath_dist,vn,i)
                         # writte pfb file
                         pfb_writer(X0,Y0,Z0,NX,NY,NZ,DX,DY,DZ,intresh,ix,iy,iz,nx,ny,nz,rx,ry,rz,ns,fn)
                         print 'Fully distributed %s.%06d.pfb: created' % (vn,i)
                     elif (distype==2):
                         DSWR = np.nanmean(dswr_data[i,:])
                         DSWR_data2D = pfbdata2D + DSWR
                         vn = 'NLDAS.DSWR'
                         fn = '%s/%s.%06d.pfb' % (storPath_aggr,vn,i)
                         # writte pfb file
                         pfb_writer(X0,Y0,Z0,NX,NY,NZ,DX,DY,DZ,DSWR_data2D,ix,iy,iz,nx,ny,nz,rx,ry,rz,ns,fn)
                         print 'Aggregated %s.%06d.pfb: created' % (vn,i)

           elif clm_vars == 'UGRD':
                 print '#---------------------------------#'
                 ugrda_data = np.zeros((l0,l2))  # wind direction
                 ugrdw_data = np.zeros((l0,l2))  # wind speed
                 ugrd_data = np.zeros((l0,l2))  # u-component
                 for k in range(l3): # years
                     for j in range(l2): # number of files to read
                         data = genfromtxt(('%s%s.csv' % (st_data[j],years[k])), delimiter=',',skip_header=1)
                         data[data==-6999]=np.nan
                         for i in range(ni[k],nf[k]): # number of rows to read
                             n = i - ni[k] + n0
                             ugrda_data[n,j] = data[i,6] # get wind direction from stations
                             ugrdw_data[n,j] = data[i,7] # get wind speed from stations
                     n0 = n

                 for i in range(l0):
                     alpha = ugrda_data[i,:]
                     ws = ugrdw_data[i,:]
                     for j in range(l2):
                         rad = 4.0*np.arctan(1.0)/180.
                         ugrd_data[i,j] = -ws[j]*np.sin(rad*alpha[j]) 
                     
                     if (distype==1):
                         UGRD = ugrd_data[i,:]
                         # interpolate point scale data
                         interpolated = interpolatePSdata(clm_vars,nrows,ncols,cellsize,UGRD,pspoints)  
                         rint = interpolated.flatten()
                         intresh = rint.reshape(nrows,ncols,nZ)
                         vn = 'NLDAS.UGRD'
                         fn = '%s/%s.%06d.pfb' % (storPath_dist,vn,i)
                         # writte pfb file
                         pfb_writer(X0,Y0,Z0,NX,NY,NZ,DX,DY,DZ,intresh,ix,iy,iz,nx,ny,nz,rx,ry,rz,ns,fn)
                         print 'Fully distributed %s.%06d.pfb: created' % (vn,i)
                     elif (distype==2):
                         UGRD = np.nanmean(ugrd_data[i,:])
                         UGRD_data2D = pfbdata2D + UGRD
                         vn = 'NLDAS.UGRD'
                         fn = '%s/%s.%06d.pfb' % (storPath_aggr,vn,i)
                         # writte pfb file
                         pfb_writer(X0,Y0,Z0,NX,NY,NZ,DX,DY,DZ,UGRD_data2D,ix,iy,iz,nx,ny,nz,rx,ry,rz,ns,fn)
                         print 'Aggregated %s.%06d.pfb: created' % (vn,i)
                         
           elif clm_vars == 'VGRD':
                 print '#---------------------------------#'
                 vgrda_data = np.zeros((l0,l2))  # wind direction
                 vgrdw_data = np.zeros((l0,l2))  # wind speed'
                 vgrd_data = np.zeros((l0,l2))  # u-component
                 for k in range(l3): # years
                     for j in range(l2): # number of files to read
                         data = genfromtxt(('%s%s.csv' % (st_data[j],years[k])), delimiter=',',skip_header=1)
                         data[data==-6999]=np.nan
                         for i in range(ni[k],nf[k]): # number of rows to read
                             n = i - ni[k] + n0
                             vgrda_data[n,j] = data[i,6] # get wind direction from stations
                             vgrdw_data[n,j] = data[i,7] # get wind speed from stations
                     n0 = n
                   
                 for i in range(l0):
                     alpha = vgrda_data[i,:]
                     ws = vgrdw_data[i,:]
                     for j in range(l2):
                         rad = 4.0*np.arctan(1.0)/180.
                         vgrd_data[i,j] = -ws[j]*np.cos(rad*alpha[j])                          
                     
                     if (distype==1):
                         VGRD = vgrd_data[i,:]
                         # interpolate point scale data
                         interpolated = interpolatePSdata(clm_vars,nrows,ncols,cellsize,VGRD,pspoints)
                         rint = interpolated.flatten()
                         intresh = rint.reshape(nrows,ncols,nZ)
                         vn = 'NLDAS.VGRD'
                         fn = '%s/%s.%06d.pfb' % (storPath_dist,vn,i)
                         # writte pfb file
                         pfb_writer(X0,Y0,Z0,NX,NY,NZ,DX,DY,DZ,intresh,ix,iy,iz,nx,ny,nz,rx,ry,rz,ns,fn)
                         print '%s.%06d.pfb: created' % (vn,i)
                     elif (distype==2):
                         VGRD = np.nanmean(vgrd_data[i,:])
                         VGRD_data2D = pfbdata2D + VGRD
                         vn = 'NLDAS.VGRD'
                         fn = '%s/%s.%06d.pfb' % (storPath_aggr,vn,i)
                         # writte pfb file
                         pfb_writer(X0,Y0,Z0,NX,NY,NZ,DX,DY,DZ,VGRD_data2D,ix,iy,iz,nx,ny,nz,rx,ry,rz,ns,fn)
                         print 'Aggregated %s.%06d.pfb: created' % (vn,i)                         

           elif clm_vars == 'DLWR':
                 print '#---------------------------------#'
                 dlwr_data = np.zeros((l0,l2))
                 for k in range(l3): # years
                     for j in range(l2): # number of files to read
                         data = genfromtxt(('%s%s.csv' % (st_data[j],years[k])), delimiter=',',skip_header=1)
                         data[data==-6999]=np.nan
                         for i in range(ni[k],nf[k]): # number of rows to read
                             n = i - ni[k] + n0
                             dlwr_data[n,j] = data[i,11] # gets incoming longwave
                     n0 = n

                 for i in range(l0):
                     if (distype==1):
                         DLWR = dlwr_data[i,:]
                         # interpolate point scale data
                         interpolated = interpolatePSdata(clm_vars,nrows,ncols,cellsize,DLWR,pspoints)
                         rint = interpolated.flatten()
                         intresh = rint.reshape(nrows,ncols,nZ)
                         vn = 'NLDAS.DLWR'
                         fn = '%s/%s.%06d.pfb' % (storPath_dist,vn,i)
                         # writte pfb file
                         pfb_writer(X0,Y0,Z0,NX,NY,NZ,DX,DY,DZ,intresh,ix,iy,iz,nx,ny,nz,rx,ry,rz,ns,fn)
                         print 'Fully distributed %s.%06d.pfb: created' % (vn,i)
                     elif (distype==2):
                         DLWR = np.nanmean(dlwr_data[i,:])
                         DLWR_data2D = pfbdata2D + DLWR
                         vn = 'NLDAS.DLWR'
                         fn = '%s/%s.%06d.pfb' % (storPath_aggr,vn,i)
                         # writte pfb file
                         pfb_writer(X0,Y0,Z0,NX,NY,NZ,DX,DY,DZ,DLWR_data2D,ix,iy,iz,nx,ny,nz,rx,ry,rz,ns,fn)
                         print 'Aggregated %s.%06d.pfb: created' % (vn,i)
                       
           elif clm_vars == 'Press':
                 print '#---------------------------------#'
                 press_data = np.zeros((l0,l2))
#                 press_factor = np.array([0.8726,0.8369,0.813,0.814,0.785])
                 for k in range(l3): # years
                     for j in range(l2): # number of files to read
                         data = genfromtxt(('%s%s.csv' % (st_data[j],years[k])), delimiter=',',skip_header=1)
                         data[data==-6999]=np.nan
                         for i in range(ni[k],nf[k]): # number of rows to read
                             n = i - ni[k] + n0
#                             press_data[n,j] = data[i,14]*3386*press_factor[j]  # inhg to pa
                             press_data[n,j] = data[i,14]  # inhg to pa
#                    print n
                     n0 = n

                 for i in range(l0):
                     if (distype==1):
                         Press = press_data[i,:]
                         # interpolate point scale data
                         interpolated = interpolatePSdata(clm_vars,nrows,ncols,cellsize,Press,pspoints)
                         rint = interpolated.flatten()
                         intresh = rint.reshape(nrows,ncols,nZ)
                         vn = 'NLDAS.Press'
                         fn = '%s/%s.%06d.pfb' % (storPath_dist,vn,i)
                         # writte pfb file
                         pfb_writer(X0,Y0,Z0,NX,NY,NZ,DX,DY,DZ,intresh,ix,iy,iz,nx,ny,nz,rx,ry,rz,ns,fn)
                         print 'Fully distributed %s.%06d.pfb: created' % (vn,i)
                     elif (distype==2):
                         Press = np.nanmean(press_data[i,:])
                         Press_data2D = pfbdata2D + Press
                         vn = 'NLDAS.Press'
                         fn = '%s/%s.%06d.pfb' % (storPath_aggr,vn,i)
                         # writte pfb file
                         pfb_writer(X0,Y0,Z0,NX,NY,NZ,DX,DY,DZ,Press_data2D,ix,iy,iz,nx,ny,nz,rx,ry,rz,ns,fn)
                         print 'Aggregated %s.%06d.pfb: created' % (vn,i)

           elif clm_vars == 'SPFH':
                 print '#---------------------------------#'
                 rh_data = np.zeros((l0,l2))
                 tc_data = np.zeros((l0,l2))
                 spfh_data = np.zeros((l0,l2))
                 press_data = np.zeros((l0,l2))
                 for k in range(l3): # years
                     for j in range(l2): # number of files to read
                         data = genfromtxt(('%s%s.csv' % (st_data[j],years[k])), delimiter=',',skip_header=1)
                         data[data==-6999]=np.nan
                         for i in range(ni[k],nf[k]): # number of rows to read
                             n = i - ni[k] + n0
                             rh_data[n,j] = data[i,5]
                             tc_data[n,j] = data[i,2]
#                             press_data[n,j] = data[i,14]*3386*press_factor[j]
                             press_data[n,j] = data[i,14]
                     n0 = n

#                       obs: It needs some revision on units conversion
                 for i in range(l0):
                     for j in range(l2):
                         Pa = press_data[i,j];                              
                         TaC = tc_data[i,j]
                         es = 6.1121*np.exp((17.27*TaC)/(237.3+TaC))*100     # Saturation vapor pressure [hPa] or [mbar]
                         RHum = rh_data[i,j]                                 # get relative humidity
                         ea = (RHum/100.0)*es
                         spfh_data[i,j] = 0.622*ea/Pa

                     if (distype==1):
                         SPFH = spfh_data[i,:]
                         # interpolate point scale data
                         interpolated = interpolatePSdata(clm_vars,nrows,ncols,cellsize,SPFH,pspoints)
                         rint = interpolated.flatten()
                         intresh = rint.reshape(nrows,ncols,nZ)
                         vn = 'NLDAS.SPFH'
                         fn = '%s/%s.%06d.pfb' % (storPath_dist,vn,i)
                         # writte pfb file
                         pfb_writer(X0,Y0,Z0,NX,NY,NZ,DX,DY,DZ,intresh,ix,iy,iz,nx,ny,nz,rx,ry,rz,ns,fn)
                         print 'Fully distributed %s.%06d.pfb: created' % (vn,i)                                                                          # ea*0.01: #ea in kpa
                     elif (distype==2):
                         SPFH = np.nanmean(spfh_data[i,:])
                         SPFH_data2D = pfbdata2D + SPFH
                         vn = 'NLDAS.SPFH'
                         fn = '%s/%s.%06d.pfb' % (storPath_aggr,vn,i)
                         # writte pfb file
                         pfb_writer(X0,Y0,Z0,NX,NY,NZ,DX,DY,DZ,SPFH_data2D,ix,iy,iz,nx,ny,nz,rx,ry,rz,ns,fn)
                         print 'Aggregated %s.%06d.pfb: created' % (vn,i)                         


# Lower Weather - Elevation 1151m 0.72
# Treeline Weather - Elevation 1610m 0.68
# Lower Deer Weather - Elevation 1850m 0.6735
# Shingle Creek Weather - Elevation 2010m 0.67
# Bogus Ridge Weather - Elevation 2114m 0.64


#distype = 1         # Fully distributed
distype = 2         # Aggregated

storPath_dist = '/home/miguel/PS_Data/dist'
storPath_aggr = '/home/miguel/PS_Data/aggr'
#storPath = '/Users/miguel/Desktop/Falcon_Inputs/interpolated_pointscale_all'

# Weather Station data
st_data = ['../Lower_Weather/LowerWeather_HrlySummary_',
           '../Treeline/Treeline_HrlySummary_',
           '../Lower_Deer_Point/LDP_HrlySummary_',
           '../Shingle_Creek_Ridge/SCR_HrlySummary_',
           '../Bogus_Ridge/BRW_HrlySummary_']

clm_vars = ['APCP',
           'DLWR',
           'DSWR',
           'Press',
           'SPFH',
           'Temp',
           'UGRD',
           'VGRD']

years = ['2013','2014']

ni = np.array([6547,0]) # starting time each year
nf = np.array([8760,4338]) # ending time each year

# creates an array to store all data collected
subs_n = nf-ni
l0 = np.int(np.sum(subs_n)-1)
l1 = len(clm_vars)
l2 = len(st_data)
l3 = len(years)
psdata = np.zeros((l0,l1))


nrows = 300
ncols = 315
cellsize = 30.0
nZ = 1

# Data for pfb file structure
pfbdata2D = np.zeros((nrows,ncols,nZ))
# Grid data
X0 = 0; Y0 = 0; Z0 = 0
NX = ncols; NY = nrows; NZ = nZ
DX = cellsize; DY = cellsize; DZ = 0
ns = 1
# Subgrids data
ix = 0; iy = 0; iz = 0
nx = ncols; ny = nrows; nz = 1
rx = 0; ry = 0; rz = 0


# Point location in DCEW to interpolate pp
pspoints = np.array([[20,47],    # Lower Weather
                    [175,124],   # Treeline Weather
                    [201,174],   # Lower Deer
                    [105,235],   # Shingle Creek
                    [282,257]]) # Bogus Ridge

ncpu = len(clm_vars)

if __name__ == "__main__":
    
    ticT = time.clock()
    
    # An array for the processes.
    jobs = []

   # Start ncpus processes.
    for i in range(ncpu):
        p = mp.Process(target= PS2Ppfb, args=(clm_vars[i],psdata,pspoints,storPath_dist,storPath_aggr,st_data,years,l0,l1,l2,l3,ni,nf,
                                              nrows,ncols,cellsize,X0,Y0,Z0,NX,NY,NZ,DX,DY,DZ,ix,iy,iz,nx,ny,nz,rx,
                                              ry,rz,ns,nZ,distype,))
        jobs.append(p)
    # Start the processes	
    for j in jobs:
        j.start()
    # Ensure all of the processes have finished
    for j in jobs:
        j.join()
        
    print "All processes have finished."
    elapsedT = time.clock()-ticT
    print 'elapsed time: %f sec' % elapsedT