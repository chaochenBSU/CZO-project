# I'll just keep the working version, and not touched agian; editing the applied version below them. Chao Chen, Mar 7 2018
# Original codes are from Miguel
############################################################################################################################
# -*- coding: utf-8 -*-
"""
Created on Thu Sep 11 11:19:32 2014

@author: Miguel Aguayo
"""

import matplotlib.pyplot as plt
import pfb_functions as pfn
import numpy as np
import csv

# define case names, the output figure frequency
figure_output_frequency = 100
case_namelist = ['pf1_base1','pf1_base5','pf1_base10','pf1_base20','pf1_base40',
                 'pf2_base1','pf2_base5','pf2_base10','pf2_base20','pf2_base40']
#case_namelist = ['pfclm1_base1','pfclm1_base40','pfclm2_base1','pfclm2_base40']
#layer_thicknesslist = [
#[2,
#0.0456,
#0.0228,
#0.0228,
#0.0171,
#0.0057,
#0.0182,
#0.0137,
#0.0137,
#0.0137,
#0.0137,
#0.0137,
#0.0114,
#0.0091,
#0.0046,
#0.0023
#],
#[2,
#1.8232,
#0.9116,
#0.9116,
#0.6837,
#0.2279,
#0.0182,
#0.0137,
#0.0137,
#0.0137,
#0.0137,
#0.0137,
#0.0114,
#0.0091,
#0.0046,
#0.0023,
#]
#]
# all five soil thickness
layer_thicknesslist = [
[2,
0.0456,
0.0228,
0.0228,
0.0171,
0.0057,
0.0182,
0.0137,
0.0137,
0.0137,
0.0137,
0.0137,
0.0114,
0.0091,
0.0046,
0.0023
],
[2,
0.2279,
0.1139,
0.1139,
0.0855,
0.0285,
0.0182,
0.0137,
0.0137,
0.0137,
0.0137,
0.0137,
0.0114,
0.0091,
0.0046,
0.0023],
[2,
0.4558,
0.2279,
0.2279,
0.1709,
0.057,
0.0182,
0.0137,
0.0137,
0.0137,
0.0137,
0.0137,
0.0114,
0.0091,
0.0046,
0.0023],
[2,
0.9116,
0.4558,
0.4558,
0.3418,
0.1139,
0.0182,
0.0137,
0.0137,
0.0137,
0.0137,
0.0137,
0.0114,
0.0091,
0.0046,
0.0023],
[2,
1.8232,
0.9116,
0.9116,
0.6837,
0.2279,
0.0182,
0.0137,
0.0137,
0.0137,
0.0137,
0.0137,
0.0114,
0.0091,
0.0046,
0.0023,
]
]
#for case_num in range (4):
for case_num in range (10):
    case_name = case_namelist [case_num]
    a=int(round(case_num/2))
    layer_thickness = layer_thicknesslist [a]
    fpath = '/home/chaochen/payette/chaochen/CZO/Chao/Demonstration_example/landlab_Const.Saprolite/outputs_%s' % (case_name)

# define output file path
    sfpath = '/home/chaochen/payette/chaochen/CZO/Chao/Demonstration_example/landlab_Const.Saprolite/postprocessing'
    outputfile_name = 'subsurface_storage_%s.csv' % (case_name)
    with open(outputfile_name, mode='w') as written_file:
    
        for time_step in range (700):
            print time_step
            fname_sat = '%s/%s.out.satur.%05d.pfb' %(fpath,case_name, time_step)
            specific_storage = '%s/%s.out.specific_storage.pfb' %(fpath,case_name)  # here the specific storage is 0.0001
            fname_press = '%s/%s.out.press.%05d.pfb' %(fpath,case_name, time_step)
            fname_porosity = '%s/%s.out.porosity.pfb' %(fpath,case_name)
            
            satur = pfn.read(fname_sat)
            spstorage = pfn.read(specific_storage)
            press = pfn.read(fname_press)
            porosity = pfn.read(fname_porosity)
            total_V=np.zeros((198,198))
            
            for layer_num in range (16):
                print layer_num
                layer_satur = satur[:,:,layer_num]
                layer_spstorage = spstorage[:,:,layer_num]
                layer_press = press[:,:,layer_num]
                layer_porosity = porosity[:,:,layer_num]
                thickness_index= layer_thickness[layer_num]
                
          
#                V_compressive = layer_satur*layer_spstorage*layer_press*30*30*thickness_index*5
#                V_imcompressive = layer_satur*layer_porosity*30*30*thickness_index*5
                V_imcompressive = layer_satur*layer_porosity*thickness_index*5
#                total_V_temp =V_compressive+V_imcompressive
                total_V_temp =V_imcompressive
                total_V=total_V+total_V_temp
#                a=total_V.sum()
                a=total_V.mean()
        # write into csv file
            data_writer = csv.writer(written_file, delimiter=',')
            data_writer.writerow([time_step,a])       
        # write some plots
            if time_step%figure_output_frequency==0:
                plt.figure(figsize=(10, 7))
                plt.pcolor(total_V,cmap='jet')
                plt.colorbar()
                plt.savefig('%s/%s_subsurfacestorage_%05d.png'% (sfpath,case_name,time_step))
                plt.close()
    written_file.close()
        

        



 
