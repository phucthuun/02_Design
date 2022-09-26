# -*- coding: utf-8 -*-
"""
Created on Tue Feb  1 16:05:10 2022

This script makes grounding and label pattern

@author: uyenn
"""


#%%


def make_pattern(NeuronAll, nNeuronShared, nSet, nNeuronUnique, nInstance):
    
    
    
    pickList = []
    pickAll = []
    dict_patt = {'Set': [], 'Instance': [], 'ActiveNeuron': []}
    # This function searches for n neurons for k sets.
    # Searching is non-exhaustive until it has found n sets that 
    # satisfy criteria 
    
    # larger loop i for Set: find [nNeuronShared] for each of the [nSet]
    availableSet = 0
    for i in itertools.count(start=1):
        print("\n--------------------------------")
        print("Set search iteration %d" %i)
        current_pool = [cell for cell in NeuronAll if cell not in pickAll]
        current_pick = random.sample(current_pool, nNeuronShared)
        
        # Criterion 1: [size] neurons in the current_pick set are not nearby each other
        # Add: nNeuronShared > 0 >> detect neighbors
        if nNeuronShared >0:
            detect_neighbor = any_neurons_nearby(current_pick, maxDistance)
        elif nNeuronShared == 0:
            detect_neighbor = 0
        
        if detect_neighbor == 0:
            
            availableSet += 1
            pickAll = pickAll + current_pick
            pickList.append(current_pick)
            NeuronShared =  current_pick
            print("Set %d: shared neurons detected!\n"%availableSet)
            # smaller loop j for Instance: find nNeuronUnique for the current set of NeuronShared
            availableInstance = 0
            all_unique_pick = []
            print("Instance search")
            for j in itertools.count(start=1):
                print("j %d"%j)
                current_pool = [cell for cell in NeuronAll if cell not in pickAll]
                current_pick = random.sample(current_pool, nNeuronUnique)
                
                # Criterion 1: [size] neurons in the current_pick set are not neighbor
                detect_neighbor = any_neurons_nearby(current_pick+NeuronShared+all_unique_pick, maxDistance)
            
                if detect_neighbor == 0:
                    
                    availableInstance += 1
                    pickAll = pickAll + current_pick
                    pickList.append(current_pick)
                    NeuronUnique =  current_pick
                    
                    # convert from 2d to 1d
                    ActiveNeuron2d = NeuronShared+NeuronUnique
                    ActiveNeuron = []
                    for activeneuron in ActiveNeuron2d:
                        AN = conv_to_felix(activeneuron)
                        ActiveNeuron += [AN]
                                        
                    dict_patt['Set'] += [availableSet]
                    dict_patt['Instance'] += [availableInstance]
                    dict_patt['ActiveNeuron'] += [ActiveNeuron]
                    all_unique_pick += current_pick
                    print("Instance %d: unique neurons detected!\n"%availableInstance)
                      
                    
                elif detect_neighbor > 0:
                    print("Nearby neurons detected!")
                
                    
                
                # Have we got enough [nset] sets?
                if availableInstance == nInstance: 
                    break
          
            
        elif detect_neighbor > 0:
            print("Nearby neurons detected!")
        
        # Have we got enough [nset] sets?
        if availableSet == nSet: 
            print("\nAll sets detected!")
            break
        
    return dict_patt



#%%

def concatenate_pairwise(list1, list2):
    concatenateList = []
    if len(list1) == len(list2):
        for current_i in range(len(list1)):
            current_concatenateList = list1[current_i]+list2[current_i]
            concatenateList.append(current_concatenateList)
    return(concatenateList)


