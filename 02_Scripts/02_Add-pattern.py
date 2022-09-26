# -*- coding: utf-8 -*-
"""
Created on Sat Jan 29 17:12:18 2022

@author: uyenn
"""
#%%

import numpy as np
import pandas as pd
import random
import math
import itertools
import sys


directory_path = "D:\\04_BrainLanguage\\02_Design" 
scripts_path = directory_path  + '\\02_Scripts\\'
confun_path = directory_path + '\\02_Scripts\\01_Funcon\\'
data_path = directory_path + '01_Data\\'

filename  = input('Which file to retrieve (e.g., senspatt/motpatt) >>> ')

#%% Initial specs
size_x = 25 
size_y =25


execfile(confun_path+"conv_to_felix.py")
execfile(confun_path+"neighbor_neuron.py")


#%% Preprocess txt file
df_senspatt_training = pd.read_csv("%s%s.txt"%(data_path,filename), header = None, names = ["ActiveNeuron"])

Set = np.concatenate([np.array(range(1,11,1))]*3)
Instance= np.repeat([1,2,3],10)

df_senspatt_training = df_senspatt_training.assign(**{'Set': Set, 'Instance': Instance})[['Set','Instance', 'ActiveNeuron']]



# Look for activated neurons by each concept
dict_NeuronTrainingSet = {'Set': [], 'ActiveNeuron': [], 'SharedNeuron' : []}

for set in np.unique(Set):
    current_df = df_senspatt_training.query(f"Set == {set}")
    current_NeuronTraining = ';'.join(current_df.loc[:,'ActiveNeuron'].values) # save as string
    current_NeuronTraining = [int(s) for s in current_NeuronTraining.split(";") if s.isdigit()] # save as integer
    current_NeuronShared = list(np.unique([x for x in current_NeuronTraining if current_NeuronTraining.count(x) > 1])) # find duplicated neurons in a set >> shared neurons
    current_NeuronTraining = list(np.unique(current_NeuronTraining))
    
    dict_NeuronTrainingSet['Set'] += [set]
    dict_NeuronTrainingSet['ActiveNeuron'] += [current_NeuronTraining]
    dict_NeuronTrainingSet['SharedNeuron'] += [current_NeuronShared]
    del current_df, current_NeuronTraining, current_NeuronShared 
    
    
df_NeuronTrainingSet = pd.DataFrame(dict_NeuronTrainingSet)
del dict_NeuronTrainingSet, set
   
# Look for the total of activated neurons during training
NeuronTraining = ';'.join(df_senspatt_training.loc[:,'ActiveNeuron'].values) # save as string
NeuronTraining = [int(s) for s in NeuronTraining.split(";") if s.isdigit()] # save as integer
NeuronTraining = list(np.unique(NeuronTraining))


#%%
NeuronAll = list(range(1,25*25+1,1)) 
NeuronTest = [neuron for neuron in NeuronAll if neuron not in NeuronTraining]


#%%

# Add new stims for test
size_x = 25
size_y = 25

NeuronAll = list(range(1,25*25+1,1))


nNeuronUnique = 6
nInstance = 3

def make_pattern(NeuronTest, df_NeuronTrainingSet, nNeuronUnique, nInstance):
    
    pickList = []
    pickAll = []
    activeNeuron = []
    dict_patt = {'Set': [], 'Instance': [], 'ActiveNeuron': []}
    # This function searches for n neurons for k sets.
    # Searching is non-exhaustive until it has found n sets that 
    # satisfy criteria 
    
    # larger loop i for Set: find [nNeuronShared] for each of the [nSet]
    availableSet = 0
    
    
    
    for set in df_NeuronTrainingSet.loc[:,'Set'].values:
        current_df_NeuronTrainingSet = df_NeuronTrainingSet.query(f"Set == {set}")
        print("\n--------------------------------")
        print("Set %d" %set)
        
        
        
        NeuronShared = current_df_NeuronTrainingSet.loc[:,'SharedNeuron'].tolist()
        NeuronShared = [int(neuron) for sublist in NeuronShared for neuron in sublist]
        NeuronTraining = current_df_NeuronTrainingSet.loc[:,'ActiveNeuron'].tolist()
        NeuronTraining = [int(neuron) for sublist in NeuronTraining for neuron in sublist]
        # smaller loop j for Instance: find nNeuronUnique for the current set of NeuronShared
        availableInstance = 0
        all_unique_pick = []
        print("Instance search")
        for j in itertools.count(start=1):
            print("j %d"%j)
            current_pool = [cell for cell in NeuronTest if cell not in pickAll]
            current_pick = random.sample(current_pool, nNeuronUnique)
            
            # Criterion 1: [size] neurons in the current_pick set are not neighbor
            search_for_neighbor_neurons_in_this_list = current_pick+NeuronTraining+all_unique_pick
            sfnnitl_xy = [tuple(conv_to_xy(neuron)) for neuron in search_for_neighbor_neurons_in_this_list] 
            detect_neighbor = any_neurons_nearby(sfnnitl_xy, math.sqrt(2))
                        
            if detect_neighbor == 0:
                availableInstance += 1
                pickAll = pickAll + current_pick
                pickList.append(current_pick)
                NeuronUnique =  current_pick
                ActiveNeuron = NeuronShared+NeuronUnique
                dict_patt['Set'] += [set]
                dict_patt['Instance'] += [availableInstance+3]
                dict_patt['ActiveNeuron'] += [ActiveNeuron]
                all_unique_pick += current_pick
                print("Instance %d: unique neurons detected!"%availableInstance)
                
            elif detect_neighbor > 0:
                print("Neighbor neurons detected!")
                    
            # Have we got enough [nset] sets?
            if availableInstance == nInstance:
                break
          
        
    return dict_patt


#%%

dict_patt = make_pattern(NeuronTest, df_NeuronTrainingSet, nNeuronUnique, nInstance)

df_NeuronTestSet = pd.DataFrame(dict_patt)
df_NeuronTestSet['ActiveNeuron']=[';'.join(map(str, l)) for l in df_NeuronTestSet['ActiveNeuron']] # to save in the same csv column

df_patt = pd.concat([df_senspatt_training, df_NeuronTestSet]).reset_index(drop=True) 
df_patt = df_patt.sort_values(["Instance","Set"], ascending = (True,True))

df_patt['ActiveNeuron'].to_csv(data_path+filename+'.csv', sep='\t',header = False, index=False)
