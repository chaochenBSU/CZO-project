# -*- coding: utf-8 -*-
"""
Created on Wed Mar 11 16:24:38 2015

@author: Miguel Aguayo
"""
import struct
import numpy as np

def read(fn):
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
        var = np.empty((np.int(ny),np.int(nx),np.int(nz)))
        
        for i0 in np.arange(ns):
            ix = np.fromfile(fid,dtype='>i4', count=1)
            iy = np.fromfile(fid,dtype='>i4', count=1)
            iz = np.fromfile(fid,dtype='>i4', count=1)
        
            nnx = np.fromfile(fid,dtype='>i4', count=1)
            nny = np.fromfile(fid,dtype='>i4', count=1)
            nnz = np.fromfile(fid,dtype='>i4', count=1)
       
            rx = np.fromfile(fid,dtype='>i4', count=1) 
            ry = np.fromfile(fid,dtype='>i4', count=1)
            rz = np.fromfile(fid,dtype='>i4', count=1)
            
            for k in np.arange(iz,iz+nnz):
                for i in np.arange(iy,iy+nny):
                    for j in np.arange(ix,ix+nnx):
                        var[i,j,k]=np.fromfile(fid,dtype='>f8', count=1)
        return var    
    
def write(x1,y1,z1,nx,ny,nz,dx,dy,dz,V1,ix,iy,iz,nnx,nny,nnz,rx,ry,rz,ns,fn):
    
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
        
        for i0 in np.arange(ns):
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

            for k in np.arange(iz,iz+nnz):
                #print 'k = %i' %k
                for i in np.arange(iy,iy+nny):
                    #print 'i = %i' %i
                    for j in np.arange(ix,ix+nnx):
                        #print 'j = %i' %j
                        print (V1[i,j,k])
                        VAR = struct.pack('>d',V1[i,j,k])
                        fid.write(VAR)
#                        
#            return i0
