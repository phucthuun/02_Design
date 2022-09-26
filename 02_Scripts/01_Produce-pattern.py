# -*- coding: utf-8 -*-
"""
Created on Tue Feb  1 16:05:40 2022


This script creates grounding patterns.
By default, it produces ground patterns for sens and mot. Criteria: Neurons of the same concept
are no direct neighbor or second-next neighbor to each other. 

@author: uyenn
"""
#%%

import numpy as np
import pandas as pd
import random
import math
import itertools
import sys


scripts_path = "D:\\04_BrainLanguage\\02_Design\\02_Scripts\\"
confun_path = "D:\\04_BrainLanguage\\02_Design\\02_Scripts\\01_Funcon\\"
data_path = "D:\\04_BrainLanguage\\02_Design\\01_Data\\"

#%%
# Some specifications


manualspec = input("Manual specs? (y/n) >>> ")
if manualspec == 'y':
    nNeuronShared = int(input("Enter nNeuronShared (=6): "))
    nNeuronUnique = int(input("Enter nNeuronUnique (=6): "))
    nSet = int(input("Enter nSet (=10): "))
    nInstance = int(input("Enter nInstance (=6): "))
    # Which neighbors should be excluded: immediate = math.sqrt(2); second-next = 2*math.sqrt(2)
    maxDistance = eval(input("Enter maxDistance (=2*math.sqrt(2)): "))
    # Size of area
    size_x = eval(input("Enter matrix size_x (=25): "))
    size_y = eval(input("Enter matrix size_y (=25): "))
else:
    nNeuronShared  = 6
    nNeuronUnique = 6
    nSet = 10
    nInstance = 6
    # Which neighbors should be excluded: immediate = math.sqrt(2); second-next = 2*math.sqrt(2)
    maxDistance = 2*math.sqrt(2)
    # Size of area
    size_x = 25
    size_y = 25
    
NeuronAll =[]
for i in range(0,size_x):
    for j in range(0,size_y):
        NeuronAll.append((i,j))

execfile(confun_path+"neighbor_neuron.py")
execfile(confun_path+"conv_to_felix.py")
execfile(confun_path+"make_pattern.py")


#%%

# Make pattern for shared neurons >> for sens and mot

namethecsv = input('Want to name the csv? (y/n) >>> ')

if  namethecsv == 'y':
    csvname = input('csv file name(s) (e.g., senspatt-2d-jump.csv) >>> ')
    csvname = csvname.split()
elif namethecsv == 'n': 
    csvname = ['senspatt-jump.txt','motpatt-jump.txt']

for i in range(len(csvname)):
    dict_patt = make_pattern(NeuronAll, nNeuronShared, nSet, nNeuronUnique, nInstance)
    # Create DataFrame  
    df_patt  = pd.DataFrame(dict_patt) 
    df_patt = df_patt.sort_values(["Instance","Set"], ascending = (True,True))
    df_patt['ActiveNeuron']=[';'.join(map(str, l)) for l in df_patt['ActiveNeuron']] # to save in the same csv column
    df_patt['ActiveNeuron'].to_csv(data_path+csvname[i], sep='\t',header = False, index=False)
    
#%%          
# Test the resulting pattern
ActiveNeuron = dict_patt['ActiveNeuron']

# Look for the total number of activated neurons
flat_list = [item for sublist in ActiveNeuron for item in sublist] # 60 instances * 12 neurons = 720
flat_list_unique = [[list(x)] for x in set(tuple(x) for x in flat_list)]
        
