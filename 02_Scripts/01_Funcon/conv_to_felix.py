# -*- coding: utf-8 -*-
"""
Created on Mon Feb 14 00:57:01 2022

@author: uyenn
"""

def conv_to_felix(coordinates):
    a = coordinates[0]
    b = coordinates[1]
    return str(a*size_x+b+1)


def conv_to_xy(neuron):
    x = int(neuron%size_x)   
    y = int(neuron/size_x)
    return (x,y)
