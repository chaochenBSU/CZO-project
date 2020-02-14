# -*- coding: utf-8 -*-
"""
Created on Thu Sep 11 11:19:32 2014

@author: Miguel Aguayo
"""

import matplotlib.pyplot as plt
import pfb_functions as pfn

nf1 = 756;
nf2 = 756;

for nf in range(nf1,nf2+1):
#-----parflow outputs    
    fn = 'pfclmwrf_DCEW_90m.out.satur.%05d.pfb' % nf
    satur = pfn.read(fn)

top_satur = satur[:,:,19]
plt.figure(figsize=(10, 7))
plt.pcolor(top_satur,cmap='jet')
plt.colormap()    
plt.show()                
