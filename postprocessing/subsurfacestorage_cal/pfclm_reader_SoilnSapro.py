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
import pandas as pd
#import csv

# define case names, the output figure frequency
figure_output_frequency = 4
#case_namelist = ['pf1_base1','pf1_base5','pf1_base10','pf1_base20','pf1_base40',
#                 'pf2_base1','pf2_base5','pf2_base10','pf2_base20','pf2_base40']
case_namelist = ['pfclm1_base1','pfclm1_base40','pfclm2_base1','pfclm2_base40']

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
], #start from here repeat the case 1,40
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
# all five soil thickness
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
#0.2279,
#0.1139,
#0.1139,
#0.0855,
#0.0285,
#0.0182,
#0.0137,
#0.0137,
#0.0137,
#0.0137,
#0.0137,
#0.0114,
#0.0091,
#0.0046,
#0.0023],
#[2,
#0.4558,
#0.2279,
#0.2279,
#0.1709,
#0.057,
#0.0182,
#0.0137,
#0.0137,
#0.0137,
#0.0137,
#0.0137,
#0.0114,
#0.0091,
#0.0046,
#0.0023],
#[2,
#0.9116,
#0.4558,
#0.4558,
#0.3418,
#0.1139,
#0.0182,
#0.0137,
#0.0137,
#0.0137,
#0.0137,
#0.0137,
#0.0114,
#0.0091,
#0.0046,
#0.0023],
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




# define output file path
sfpath = '/home/chaochen/payette/chaochen/CZO/Chao/Demonstration_example/landlab_Const.Saprolite/postprocessing'
outputfile_soilname = 'pfclm_soil_storage.csv'
outputfile_saproname = 'pfclm_sapro_storage.csv'

num_case=len(case_namelist)

data_length=336 #168 for pfclm

soilwater_matrix = np.zeros((data_length,num_case),dtype=float)
saprowater_matrix = np.zeros((data_length,num_case),dtype=float)

ncols=198
nrows=198
nlayers=16




        
        
def thickness_dom (layer_thickness,ncols,nrows,nlayers):
    thick_dom = np.zeros((ncols,nrows,nlayers),dtype=float)
    for i in range(nlayers):
        thick_dom[:,:,i] = thick_dom[:,:,i] + layer_thickness[i]*5
    return thick_dom



def subsurface_storage (fpath,data_length,num_case,ncols,nrows,case_name,time_step,thick_dom):

    print (time_step)
    fname_sat = '%s/%s.out.satur.%05d.pfb' %(fpath,case_name, time_step)
#    specific_storage = '%s/%s.out.specific_storage.pfb' %(fpath,case_name)  # here the specific storage is 0.0001
#    fname_press = '%s/%s.out.press.%05d.pfb' %(fpath,case_name, time_step)
    fname_porosity = '%s/%s.out.porosity.pfb' %(fpath,case_name)
    
    satur = pfn.read(fname_sat)
#    spstorage = pfn.read(specific_storage)
#    press = pfn.read(fname_press)
    porosity = pfn.read(fname_porosity)
#    total_V=np.zeros((ncols,nrows))
    
    depth_imcompressive = satur*porosity*thick_dom  #in unit of meter
    # get all soil layers from domain from soil bottom layer and above
    mask_ws_soil  =  depth_imcompressive[:,:,6:]
    mask_ws_sapro =  depth_imcompressive[:,:,1:6]
    # sum soil water storage for all cells
    total_soilwater_depth = np.sum(mask_ws_soil, axis=2)
    total_saprowater_depth = np.sum(mask_ws_sapro, axis=2)

    return total_soilwater_depth,total_saprowater_depth

    #                V_compressive = layer_satur*layer_spstorage*layer_press*30*30*thickness_index*5
    #                V_imcompressive = layer_satur*layer_porosity*30*30*thickness_index*5
    #                V_imcompressive = layer_satur*layer_porosity*thickness_index*5
    #                total_V_temp =V_compressive+V_imcompressive
    #                total_V_temp =V_imcompressive
    #                total_V=total_V+total_V_temp
    #                a=total_V.sum()

def plot_ws_2D (time_step,figure_output_frequency,total_soilwater_depth,total_saprowater_depth,sfpath,case_name):
    if time_step%figure_output_frequency==0:
        plt.figure(figsize=(10, 7))
        plt.pcolor(total_soilwater_depth,cmap='jet')
        plt.colorbar()
        plt.savefig('%s/%s_soilwaterstorage_%05d.png'% (sfpath,case_name,time_step))
        plt.close()     
    
        plt.figure(figsize=(10, 7))
        plt.pcolor(total_saprowater_depth,cmap='jet')
        plt.colorbar()
        plt.savefig('%s/%s_saprowaterstorage_%05d.png'% (sfpath,case_name,time_step))
        plt.close()

def plot_ws_1D (time_step, total_soilwater_depth,total_saprowater_depth):  
    a=total_soilwater_depth.mean()
    b=total_saprowater_depth.mean()
    soilwater_matrix[time_step,case_index]=a
    saprowater_matrix[time_step,case_index]=b
    return soilwater_matrix,saprowater_matrix       

def write_ws_1D (outputfile_soilname,outputfile_saproname,soilwater_matrix,saprowater_matrix):
    np.savetxt(outputfile_soilname,soilwater_matrix,delimiter=",")
    np.savetxt(outputfile_saproname,saprowater_matrix,delimiter=",")


def outlier_remove(data_matrix):
    data_matrix_smooth=data_matrix
    [N_rows, N_col]=data_matrix.shape
    
    for j in range (Y): 
        for i in range (1,X-1):
            diff=(data_matrix[i-1,j]-data_matrix[i,j])/data_matrix[i-1,j]
            if diff>0.2:
                data_matrix_smooth[i,j]=(data_matrix[i-1,j]-data_matrix[i+1,j])/2
    return data_matrix_smooth

def time_series_plot (data_matrix,column_title):
    pd.DataFrame(data=data_matrix, columns=column_title)  # 1st row as the column names
    pd.DataFrame.plot(x='hour', y='pfclm1_base1')






# Main function
if __name__ == "__main__":
    for case_index in range (num_case):
        case_name = case_namelist [case_index]
        layer_thickness = layer_thicknesslist [case_index]
        fpath = '/home/chaochen/payette/chaochen/CZO/Chao/Demonstration_example/landlab_Const.Saprolite/extended_simulation/outputs_%s' % (case_name)
        
        for time_step in range (data_length):
            thick_dom=thickness_dom(layer_thickness,ncols,nrows,nlayers)
            (total_soilwater_depth,total_saprowater_depth)=subsurface_storage (fpath,data_length,num_case,ncols,nrows,case_name,time_step,thick_dom)
#            plot_ws_2D (time_step,figure_output_frequency,total_soilwater_depth,total_saprowater_depth,sfpath,case_name)
            if time_step%data_length:
                plot_ws_1D (time_step, total_soilwater_depth,total_saprowater_depth)
                write_ws_1D (outputfile_soilname,outputfile_saproname,soilwater_matrix,saprowater_matrix)
                
        