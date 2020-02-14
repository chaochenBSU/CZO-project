# -*- coding: utf-8 -*-
"""
Created on Tue May 10 17:25:13 2016

@author: miguel
"""
import os

ni = 4901
nf = 4995

var_data = ['satur',
            'press',
            'et',
            'obf',
            'clm_output']
            
#var_data = ['press']

serverpath = 'aguamigu@hpclogin.inl.gov:/home/aguamigu/simulations/parflow_sim/PFCLMWRF_DCEW30m/WY2014/pfclmwrf_DCEW30m_ps_aggr'
#serverpath = 'aguamigu@hpclogin.inl.gov:/home/aguamigu/.snapshot/hourly_2018-02-23-_09-30/simulations/parflow_sim/PFCLMWRF_DCEW30m/WY2014/pfclmwrf_DCEW30m_ps_aggr'
#serverpath = 'aguamigu@hpclogin.inl.gov:/home/aguamigu/.snapshot/hourly_2018-02-26-_07-30/simulations/parflow_sim/PFCLMWRF_DCEW30m/WY2014/pfclmwrf_DCEW30m_ps_aggr'
#serverpath = 'aguamigu@hpclogin.inl.gov:/home/aguamigu/.snapshot/hourly_2018-02-26-_20-30/simulations/parflow_sim/PFCLMWRF_DCEW30m/WY2014/pfclmwrf_DCEW30m_ps_aggr'
filepath = 'outputs_01_pfclmwrf_ps_aggr'
simname = 'pfclmwrf_DCEW_30m.out'

for j in range(len(var_data)):
    for i in range(ni,nf):
        if (var_data[j] == 'clm_output'):
            fn = '%s/%s.%s.%05d.C.pfb' % (filepath,simname,var_data[j],i)
            os.system('rsync -avP %s/%s %s' % (serverpath, fn, var_data[j]))
            print '%s.%05d.pfb : transferred!' % (var_data[j],i)
        else:
            fn = '%s/%s.%s.%05d.pfb' % (filepath,simname,var_data[j],i)
            os.system('rsync -avP %s/%s %s' % (serverpath, fn, var_data[j]))
            print '%s.%05d.pfb : transferred!' % (var_data[j],i)
