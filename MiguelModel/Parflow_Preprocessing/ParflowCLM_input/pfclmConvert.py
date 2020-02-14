# -*- coding: utf-8 -*-
"""
Created on Thu Oct 15 2015

@author: Miguel Aguayo

"""
#-------------- Convention names for input files: -------------------#

# DEM: NameOfWatershed_SpatialResolution.dem.asc (e.g DCEW_30m.dem.asc)
# NLCD: NameOfWatershed_SpatialResolution.nlcd.asc (e.g DCEW_30m.nlcd.asc)
# MODIS: NameOfWatershed_SpatialResolution.nlcd.asc (e.g DCEW_30m.modis.asc)
# Soil Texture: NameOfWatershed_SpatialResolution.soil.asc (e.g DCEW_30m.soil.asc)

#----------------------- Functions ------------------------#

# Import python numerical libraries

import numpy as np

def asciiDEM2sa(fdem,lh,pfpath):
    # This function read and convert from ascii DEM to ascii SA files for Parflow
    # Arguments:
    # fdem: convention name for input files (e.g. DCEW_30m if the file name is DCEW_30m.dem.asc)
    # lh: number of header lines to skip 

    # load data from ascii DEM
    fi = 'input_files/%s.dem.asc' % fdem
    fo = '%s/%s.dem.sa' % (pfpath,fdem)
    
    mr = np.genfromtxt(fi,skip_header=lh)
    mrsize = mr.shape
    mrrows = mrsize[0]
    mrcols = mrsize[1]
    
    # Sort data and create ParFlow .sa
    mrflip = np.flipud(mr) # flip DEM from bottom to top
    mrtran = mrflip.transpose() # Transpose DEM for column major shorting data
    mrresh = np.reshape(mrtran,mrrows*mrcols,1)
    #with file(fo, 'w') as outfile:
    hdr = "%d  %d  %d" % (mrcols,mrrows,1)
    np.savetxt(fo,mrresh,fmt='%f',delimiter="\n",header=hdr, comments='')
    print "\033[0;32m%s file... successfully created!\033[0m" % fo 
    return mrrows,mrcols

     
def asciiLCD2clmdat(dataset,flcd,lh,clmpath):
# This function read and convert from ascii Land Cover Data to ascii DAT file for CLM
# Arguments:
    # dataset: name of dataset source to use (i.e. MODIS or NLCD)
    # flcd: name of input LC file  (e.g. DCEW_30m if the file name is DCEW_30m.nlcd.asc)
    # lh: number of header lines to be skipped

    # load data from ascii NLCD (high spatial resolution 30m) or MODIS (lower resolution 500m)
    fi = 'input_files/%s.nlcd.asc' % flcd
    fo = '%s/drv_vegm.alluv.dat' % clmpath # File name
    mlc = np.genfromtxt(fi,skip_header=lh)
    #mlcloc = np.loadtxt("DCEW_NLCD30m_Loc.dat") # Location in IGBP veg matrix\
    mlcsize = mlc.shape
    mlcrows = mlcsize[0]
    mlccols = mlcsize[1]
    mlcvs = int(mlcrows*mlccols); # reshaped vector size
    #mlcv = np.zeros((mlcvs,1)); # Land cover veg matrix
    lat = np.zeros((mlcvs,1));
    lon = np.zeros((mlcvs,1));
    sand = np.zeros((mlcvs,1));
    clay = np.zeros((mlcvs,1));
    color = np.zeros((mlcvs,1));
    #index = np.zeros((mlcvs,1));
    lcd_val = np.zeros((mlcvs,1))
    veg = 18;             # number of types of vegetation [max range]
    vegmat = np.zeros((mlcvs,veg)); 
    
    # Sort data and create drv_vegm.alluv.dat
    mlcflip = np.flipud(mlc) # flip Soil data from bottom to top
    mlctran = mlcflip.transpose() # Transpose Soil array for column major shorting data
    mlcc = np.linspace(1,mlccols,mlccols)
    mlcr = np.linspace(1,mlcrows,mlcrows)
    mlcX,mlcY = np.meshgrid(mlcr,mlcc)
    Sxc = np.reshape(mlcY,mlcvs,1)
    Syc = np.reshape(mlcX,mlcvs,1)
    Szc = np.reshape(mlctran,mlcvs,1)
    
    if dataset=='NLCD':
        nlcd2clmdat(fo,lcd_val,vegmat,Sxc,Syc,Szc,lat,lon,sand,clay,color)
        print "\033[0;32m%s file... successfully created!\033[0m" % fo
    elif dataset=='MODIS':
        modis2clmdat(fo,lcd_val,vegmat,Sxc,Syc,Szc,lat,lon,sand,clay,color)
        print "\033[0;32m%s file... successfully created!\033[0m" % fo
    else:
        print "\033[0;31mError: Dataset names must be: \'NLCD\' or \'MODIS\'\033[0m"
        print "\033[0;31mError: %s for CLM cannot be created!\033[0m" % fo
        #print 'Error: %s for CLM is not created!' % fo

 
def nlcd2clmdat(fo,lcd_val,vegmat,Sxc,Syc,Szc,lat,lon,sand,clay,color):
# This sub-function tries to match IGBP classification values and write the values according with CLM format
# Arguments:
    # come from asciiLCD2clmdat function
  
# Place data in the corresponding IGBP column in drv_vegm.alluv.dat file  - 18 columns in total (modify depending on the number of land cover types)
    for i in range(len(Szc)):
        if Szc[i]==42:
            lcd_val[i]=0 # (1-1) could be in column 0 or 1
        elif Szc[i]==41:
            lcd_val[i]=2 # (3-1) could be in column 2 or 3
        elif Szc[i]==43:
            lcd_val[i]=4 # (5-1) could be in column 3 or 4
        elif Szc[i]==52:
            lcd_val[i]=6 # (7-1) could be in column 6 or 7
        elif Szc[i]==12:
            lcd_val[i]=14 # (15-1)
        elif Szc[i]==90:
            lcd_val[i]=10 # (11-1)
        elif Szc[i]==82:
            lcd_val[i]=11 # (12-1)
        elif Szc[i]==22:
            lcd_val[i]=12 # (13-1)
        elif Szc[i]==71:
            lcd_val[i]=9 # (10-1)
        elif Szc[i]==31:
            lcd_val[i]=15 # (16-1)
        elif Szc[i]==11:
            lcd_val[i]=16 # (17-1)
            
        # Only for 100% fractional coverage for each cell (i.e. 1.0) assuming that
        # the cell is complete covered by one land cover class
        vegmat[i,int(lcd_val[i])] = 1.0;
        
        # These parameters are needed to fill the 
        lat[i] = 43.683;
        lon[i] = -116.187;
        sand[i] = 0.16;
        clay[i] = 0.26;
        color[i] = 2;

    # concat vectors
    out = np.c_[Sxc,Syc,lat,lon,sand,clay,color,vegmat]
        
    # save data into file
    with file(fo, 'w') as outfile:
        outfile.write('x  y   lat     lon    sand clay color  fractional coverage '\
        'of grid by vegetation class (Must/Should Add to 1.0)\n')
        outfile.write('        (Deg)   (Deg)    (%/100)  index  1    2    3    4    5    6    ' \
        '7    8    9   10  11  12   13   14   15   16   17   18\n')
        for i in range(len(Szc)):
            outfile.write('%d   %d   %5.2f  %5.2f %4.2f %4.2f   %d %4.2f %4.2f %4.2f '\
            '%4.2f %4.2f %4.2f %4.2f %4.2f %4.2f %4.2f %4.2f %4.2f %4.2f %4.2f %4.2f '\
            '%4.2f %4.2f %4.2f\r\n'\
            % (out[i,0],out[i,1],out[i,2],out[i,3],out[i,4],out[i,5],out[i,6],out[i,7]\
            ,out[i,8],out[i,9],out[i,10],out[i,11],out[i,12],out[i,13],out[i,14]\
            ,out[i,15],out[i,16],out[i,17],out[i,18],out[i,19],out[i,20],out[i,21]\
            ,out[i,22],out[i,23],out[i,24]))
        outfile.close()

       
def modis2clmdat(fo,lcd_val,vegmat,Sxc,Syc,Szc,lat,lon,sand,clay,color):
# This sub-function uses IGBP classification values and write the values according with CLM format. No changes are needed
# Arguments:
    # come from asciiLCD2clmdat function

    for i in range(len(Szc)):
        if Szc[i]==0:
            lcd_val[i]=16 # (17-1)
        elif Szc[i]==1:
            lcd_val[i]=0 # (1-1)
        elif Szc[i]==2:
            lcd_val[i]=1 # (2-1)
        elif Szc[i]==3:
            lcd_val[i]=2 # (3-1)
        elif Szc[i]==4:
            lcd_val[i]=3 # (4-1)
        elif Szc[i]==5:
            lcd_val[i]=4 # (5-1)
        elif Szc[i]==6:
            lcd_val[i]=5 # (6-1)
        elif Szc[i]==7:
            lcd_val[i]=6 # (7-1)
        elif Szc[i]==8:
            lcd_val[i]=7 # (8-1)
        elif Szc[i]==9:
            lcd_val[i]=8 # (9-1)
        elif Szc[i]==10:
            lcd_val[i]=9 # (10-1)
        elif Szc[i]==11:
            lcd_val[i]=10 # (11-1)
        elif Szc[i]==12:
            lcd_val[i]=11 # (12-1)
        elif Szc[i]==13:
            lcd_val[i]=12 # (13-1)
        elif Szc[i]==14:
            lcd_val[i]=13 # (14-1)
        elif Szc[i]==15:
            lcd_val[i]=14 # (15-1)
        elif Szc[i]==16:
            lcd_val[i]=15 # (16-1)
            
        # Only for 100% fractional coverage for each cell (i.e. 1.0) assuming that
        # the cell is complete covered by one land cover class
        vegmat[i,int(lcd_val[i])] = 1.0;
        
        # These parameters are needed only to fill drv_vegm database 
        # (for lon/lat, use lower left corner coordinates)
        lat[i] = 43.683;
        lon[i] = -116.187;
        sand[i] = 0.16;   
        clay[i] = 0.26;
        color[i] = 2;

    # concatenate vectors   
    out = np.c_[Sxc,Syc,lat,lon,sand,clay,color,vegmat]
        
    # save data into file
    with file(fo, 'w') as outfile:
        outfile.write('x  y   lat     lon    sand clay color  fractional coverage '\
        'of grid by vegetation class (Must/Should Add to 1.0)\n')
        outfile.write('        (Deg)   (Deg)    (%/100)  index  1    2    3    4    5    6    ' \
        '7    8    9   10  11  12   13   14   15   16   17   18\n')
        for i in range(len(Szc)):
            outfile.write('%d   %d   %5.2f  %5.2f %4.2f %4.2f   %d %4.2f %4.2f %4.2f '\
            '%4.2f %4.2f %4.2f %4.2f %4.2f %4.2f %4.2f %4.2f %4.2f %4.2f %4.2f %4.2f '\
            '%4.2f %4.2f %4.2f\r\n'\
            % (out[i,0],out[i,1],out[i,2],out[i,3],out[i,4],out[i,5],out[i,6],out[i,7]\
            ,out[i,8],out[i,9],out[i,10],out[i,11],out[i,12],out[i,13],out[i,14]\
            ,out[i,15],out[i,16],out[i,17],out[i,18],out[i,19],out[i,20],out[i,21]\
            ,out[i,22],out[i,23],out[i,24]))
        outfile.close()

def asciiSoil2sa(fsoil,lh,nsl,pfpath):
# This function read and convert from ascii Soil Data to ascii SA soil file for Parflow
# Arguments:
    # fsoil: name of input soil file  (e.g. DCEW_30m if the file name is DCEW_30m.soil.asc)
    # lh: number of header lines to be skipped
    # nsl: number of soil layers

    # load data from ascii soil array
    fi = 'input_files/%s.soil.asc' % fsoil
    fo = '%s/geo_indi/%s.soil.sa' % (pfpath,fsoil)
    ms = np.genfromtxt(fi,skip_header=lh)
    #ms = np.loadtxt("input_files/DCEW_Soil30m.asc")
    mssize = ms.shape
    msrows = mssize[0]
    mscols = mssize[1]
    
    # Sort data and create ParFlow .sa
    msflip = np.flipud(ms) # flip Soil data from bottom to top
    mstran = msflip.transpose() # Transpose Soil array (column major array) 
    msc = np.linspace(1,mscols,mscols)
    msr = np.linspace(1,msrows,msrows)
    msX,msY = np.meshgrid(msr,msc)
    Sx = np.reshape(msY,msrows*mscols,1)
    Sy = np.reshape(msX,msrows*mscols,1)
    Sz = np.reshape(mstran,msrows*mscols,1)
    S = np.c_[Sx,Sy,Sz]
    hdr = "%d\t%d\t%d\t" % (mscols,msrows,nsl)
    np.savetxt(fo,S,fmt='%d',delimiter="\t",header=hdr, comments='')
    print "\033[0;32m%s file... successfully created!\033[0m" % fo 

    
def soilsa2indisa(f,inx,iny,inz,ins,pfpath):
# This function read and convert from ascii Soil Data to ascii SA soil indicator file for Parflow
# Arguments:
    # f: name of input soil file  (e.g. DCEW_30m if the file name is DCEW_30m.soil.asc)
    # inx: number of columns (x-dir)
    # iny: number of rows (y-dir)
    # inz: number of total layers
    # ins: number of soil layers (top layers)
    
    # Read indicator field from text:
    fn1 = '%s/geo_indi/%s.soil.sa' % (pfpath,f)
    fin     = open( fn1 )
    txt   = fin.readlines( )
    fin.close( )

    nx    = int(inx)      # number of columns (x-dir)
    ny    = int(iny)      # number of rows (y-dir) 
    nz    = int(inz)      # number of total layers
    ns    = int(ins)      # number of soil layers (top layers)
    soil  = np.zeros([nx,ny])
    indi  = np.zeros([nx,ny,nz])
    line  = 1
    
    for j in range(ny):
        for i in range(nx):
            soil[i,j] = float(txt[line].split()[2])
            line      = line + 1
    
    # Uniform subsurface (below soil layers). Values set to 0.0
    for k in range( nz ):
        for j in range( ny ):
            for i in range( nx ):
                if (k < nz-ns):
                    indi[i,j,k] = 0.0
                else:
                    indi[i,j,k] = soil[i,j]
                    
    # Print to file
    fn2 = '%s/geo_indi/%s.indi.sa' % (pfpath,f)
    fout = open(fn2,'w')
    print >> fout, nx, ny, nz
    for k in range(nz):
        for j in range(ny):
            for i in range(nx):
                print >> fout, indi[i,j,k]
    fout.close() 
    print "\033[0;32m%s file... successfully created!\033[0m" % fn2 
