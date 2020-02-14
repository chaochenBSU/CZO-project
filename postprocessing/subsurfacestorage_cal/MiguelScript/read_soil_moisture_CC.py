#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Tue Aug 22 10:03:54 2017

@author: miguel
"""

#import matplotlib.pyplot as plt
import multiprocessing as mp
import numpy as np

def read_ascii(fmap,lh):
    # This function read raster ascii files
    # Arguments:
    # fmap: name of file input files (e.g. DCEW_30m.dem.asc)
    # lh: number of header lines to be skipped

    # load data from ascii DEM
    fi = fmap
    mr = np.genfromtxt(fi,skip_header=lh)
    mrsize = mr.shape
    mrrows = mrsize[0]
    mrcols = mrsize[1]

    # Sort data for plotting in a correct way
    mrflip = np.flipud(mr) # flip DEM from bottom to top
    return mrrows,mrcols,mrflip

def vectSplit(vect, nproc):
    avg = len(vect) / float(nproc)
    svect = []
    last = 0.0

    while last < len(vect):
        svect.append(vect[int(last):int(last + avg)])
        last += avg
    return svect

def read_pfb(fn):
    with open(fn,'r') as fid:
        x1 = np.fromfile(fid,dtype='>f8', count=1)
        y1 = np.fromfile(fid,dtype='>f8', count=1)
        z1 = np.fromfile(fid,dtype='>f8', count=1)
        nx = np.fromfile(fid,dtype='>i4', count=1)
        ny = np.fromfile(fid,dtype='>i4', count=1)
        nz = np.fromfile(fid,dtype='>i4', count=1)
        dx = np.fromfile(fid,dtype='>f8', count=1)
        dy = np.fromfile(fid,dtype='>f8', count=1)
        dz = np.fromfile(fid,dtype='>f8', count=1)
        ns = np.fromfile(fid,dtype='>i4', count=1)
        var = np.zeros((np.int64(ny),np.int64(nx),np.int64(nz)))

        for i0 in range(ns):
            ix = np.fromfile(fid,dtype='>i4', count=1)
            iy = np.fromfile(fid,dtype='>i4', count=1)
            iz = np.fromfile(fid,dtype='>i4', count=1)

            nnx = np.fromfile(fid,dtype='>i4', count=1)
            nny = np.fromfile(fid,dtype='>i4', count=1)
            nnz = np.fromfile(fid,dtype='>i4', count=1)

            rx = np.fromfile(fid,dtype='>i4', count=1)
            ry = np.fromfile(fid,dtype='>i4', count=1)
            rz = np.fromfile(fid,dtype='>i4', count=1)

            for k in range(iz,iz+nnz):
                for i in range(iy,iy+nny):
                    for j in range(ix,ix+nnx):
                        var[i,j,k]=np.fromfile(fid,dtype='>f8', count=1)

    P = var[:,:,:]
    return P
    
def thickness_dom(thickness,nrows,ncols,nlayers):
    # create array thickness and populate it with soil layer thickness data
    # returns array thickness array
    thick_dom = np.zeros((nrows,ncols,nlayers),dtype=float)
    lt = nlayers
    for i in range(lt):
        thick_dom[:,:,i] = thick_dom[:,:,i] + thickness[i]
    return thick_dom

def get_mask(mask_map):
    # get mask coordinates for domain of interest
    itemindex = np.where(mask_map==1.0)
    c = np.asarray(itemindex)
    return c
    
def get_ws_dom(thick_dom,pfb_var,pfb_poros,m2cm):
    # calculates water storage for all domain 
    ws_dom = pfb_var*pfb_poros*thick_dom*m2cm
    return ws_dom

    
def get_ws_mask_ser(thick_dom,fn_satur,pfb_poros,m2cm,mask_ws,c,nlayers,sblayer,n):
    
    sn = len(n)
    tot_ws_soil = np.empty([sn,2])
    for t in range(sn):
        fn = '%s.%05d.pfb' % (fn_satur,n[t])
        pfb_satur = read_pfb(fn)
        # get water storage data for masked all domain    
        ws_dom = get_ws_dom(thick_dom,pfb_satur,pfb_poros,m2cm)
        # get water storage data for masked domain (dry creek)
        l = len(c[1])
        for j in range(nlayers):
            for i in range(l):
                mask_ws[c[0,i],c[1,i],j]= ws_dom[c[0,i],c[1,i],j]
 
        # get all soil layers from masked domain from soil bottom layer and above
        mask_ws_soil = mask_ws[:,:,sblayer:]
        # get total water stored
        tot_ws_soil[t,0] = n[t]
        tot_ws_soil[t,1] = np.nansum(mask_ws_soil) 
        print 'Total Soil WS at: %05d' % n[t]
        # save data in current workspace
        np.savetxt('Serial__Total.soil_ws.csv',tot_ws_soil , delimiter=",")
    return mask_ws

    
#def get_ws_mask_par(fascale,thick_dom,fn_satur,pfb_poros,m2cm,mask_ws,c,nlayers,sblayer,n,ncpu):
def get_ws_mask_par(thick_dom,fn_satur,pfb_poros,m2cm,mask_ws,nlayers,sblayer,n):    
    sn = len(n)
#    tot_ws_soil = np.empty([sn,2])
    for t in range(sn):
        fn = '%s.%05d.pfb' % (fn_satur,n[t])
        pfb_satur = read_pfb(fn)
        # get water storage data for masked all domain    
        ws_dom = get_ws_dom(thick_dom,pfb_satur,pfb_poros,m2cm)
        # get water storage data for masked domain (dry creek)
#        l = len(c[1])
#        for j in range(nlayers):
#            for i in range(l):
#                mask_ws[c[0,i],c[1,i],j]= ws_dom[c[0,i],c[1,i],j]
        
        # get all soil layers from masked domain from soil bottom layer and above
#        mask_ws_soil = mask_ws[:,:,sblayer:]
        mask_ws_soil = ws_dom[:,:,sblayer:]
        # sum soil water storage for all cells
        mask_ws_soil_cell = np.sum(mask_ws_soil, axis=2)
        # convert nan to -9999        
        mask_ws_soil_cell[np.isnan(mask_ws_soil_cell)] = -9999
        # save data as text (csv)
#        np.savetxt(('/media/miguel/Data/Soil_Water_Storage/30m/%s/DCEW_Total_soil_ws_%s.%05d.csv'
#                    % (fascale,fascale,n[t])),mask_ws_soil_cell, delimiter=",")
        np.savetxt(('/home/chaochen/payette/chaochen/CZO/Chao/Demonstration_example/landlab_Const.Saprolite/%s/DCEW_Total_soil_ws_%s.%05d.csv'
                    % (n[t])),mask_ws_soil_cell, delimiter=",")
        # get total water stored
#        tot_ws_soil[t,0] = n[t]
        # get total water storage in masked area
#        tot_ws_soil[t,1] = np.nansum(mask_ws_soil) 
        print 'Calculation of Soil WS at: %05d hrs. Done!' % n[t]
        # save results in current workspace
#        np.savetxt(('DCEW_Total_soil_ws_%s.%02d.csv' % (fascale,ncpu)),tot_ws_soil , delimiter=",")

#    return mask_ws,tot_ws_soil

# Main function
if __name__ == "__main__":
    
    ### open raster file with watershed mask
    # data file
    fdem = 'DCEW_30m.mask.asc'
    lh = 6
    mrrows,mrcols,mrflip= read_ascii(fdem,lh)
    
    ### 10 layers of soil
    thickness = np.array([2.0, ### Bottom
                          0.0456,
                            0.0228,
                            0.0228,
                            0.0171,
                            0.0057,### Soil Bottom (Soil Starts here from bottom to top)
                            0.0182,
                            0.0137,
                            0.0137,
                            0.0137,
                            0.0137,
                            0.0137,
                            0.0114,
                            0.0091,
                            0.0046,
                            0.0023]) ### Top Soil



    # create thickness array and populate it with thickness data
    nlayers = 16
    thick_dom = thickness_dom(thickness,mrrows,mrcols,nlayers)

    # get mask coordinates for domain
    c = get_mask(mrflip)    

    # create empty array to store data corresponding to the masked domain    
    mask_ws_empty = np.empty((mrrows,mrcols,nlayers)) * np.nan
    
    fpath = '/home/chaochen/payette/chaochen/CZO/Chao/Demonstration_example/landlab_Const.Saprolite'
#    fascale = '9km'  # atmospheric scale
#    fdir = 'met_res_%s/satur' % fascale
    case_namelist = ['pf1_base1','pf1_base5','pf1_base10','pf1_base20','pf1_base40',
                 'pf2_base1','pf2_base5','pf2_base10','pf2_base20','pf2_base40']
    
#    fn_satur = '%s/%s/pfclmwrf_DCEW_30m.out.satur' % (fpath,fdir)
    
#    fn_poros = 'pfclmwrf_DCEW_30m.out.porosity.pfb'
#    pfb_poros = read_pfb(fn_poros)

    
    # get water storage data and total water stored from masked domain
    m2cm = 100.0 # m to cm conversion
    sblayer = 10 # soil bottom layer ID
    ni = 1
    nf = 700
    n = np.linspace(ni,nf,(nf-ni)+1,dtype=int)

#####################################################################
################# Parallel postprocessing ###########################
#####################################################################
    # parameters for parallel process
    ncpus = mp.cpu_count() # to use all threads
    a = ni
    b = nf
    # create vector to be splitted
    vr = range(a,b)
    v = range(b-a)
    for i in range(b-a):
        v[i] = vr[i]
    svect = vectSplit(v,ncpus)

    # An array for the processes.
    jobs = []

    # Define an output queue
    output = mp.Queue()

   # Start ncpus processes.
    for i in range(ncpus):
        #p = mp.Process(target=vectCalc, args=(a,i))
        p = mp.Process(target= get_ws_mask_par, args=(fascale,thick_dom,fn_satur,
                                                      pfb_poros,m2cm,mask_ws_empty,
                                                      c,nlayers,sblayer,svect[i],i,))
        jobs.append(p)
    # Start the processes
    for j in jobs:
        j.start()
    # Ensure all of the processes have finished
    for j in jobs:
        j.join()

#####################################################################        
################### Serial postprocessing ###########################
#####################################################################        
#    # parameters for serial process
#    ncpus = 1 # use 1 proccesor
#    a = ni
#    b = nf
#    # create vector to be splitted
#    vr = range(a,b)
#    v = range(b-a)
#    for i in range(b-a):
#        v[i] = vr[i]
#    svect = vectSplit(v,ncpus)
#
#    mask_ws = get_ws_mask_ser(thick_dom,fn_satur,pfb_poros,m2cm,mask_ws_empty,c,nlayers,sblayer,svect[0])     
#
##     get a layer for plotting only
#    mask_ws1 = mask_ws[:,:,18]
#     
#    plt.figure(figsize=(10, 7))
#    m = np.ma.masked_where(np.isnan(mask_ws1),mask_ws1)
#    plt.pcolor(m,cmap='gist_ncar')
#    plt.colorbar()
    
    
    
    