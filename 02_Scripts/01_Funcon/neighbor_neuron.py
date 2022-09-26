# -*- coding: utf-8 -*-
"""
Created on Mon Jan 31 12:25:05 2022

@author: uyenn
"""

# size_x = 25
# size_y = 25

# This script looks for neightbor neurons of a given neuron

def get_distance(neuron1,neuron2):
    return math.sqrt(sum([(a - b) ** 2 for a, b in zip(neuron1,neuron2)]))

def any_neurons_nearby(selected_neurons, maxDistance = 2*math.sqrt(2)):
    # print("detecting neurons nearby...")
    for current_center_neuron in selected_neurons:
        detect_neighbor = 0
        current_other_neurons = [neuron for neuron in selected_neurons if neuron != current_center_neuron]
        
        for current_other_neuron in current_other_neurons:
            current_distance = get_distance(current_center_neuron, current_other_neuron)
            if current_distance <= maxDistance:
                detect_neighbor += 1
                break
        # print("Neuron %-10s: %s"%(current_center_neuron , detect_neighbor))
        if detect_neighbor > 0: break
    return detect_neighbor
    

#%% Test functions

# sharedneurons_pat1 = [(100,122),(2,5),(0,0),(1,1)]
# sharedneurons_pat2 = [10,100,200,300,400,500]

# a=any_neurons_nearby(sharedneurons_pat1)

    