#Copyright (C) 2023  Amalia-Artemis Koufopoulou, Athanasios Papadimitriou, Aggelos Pikrakis, Mihalis Psarakis, David Hely

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

# -*- coding: utf-8 -*-
"""
Created on Fri Nov 11 13:01:16 2022

@author: amagi

This file reads the stats_2.txt file (the error rates as derived from DBF FI) and creates the dataset structures used for the GNN operations
"""

ga = 0

import shutil
import torch
from torch_geometric.data import Data
from torch_geometric.data import InMemoryDataset
from torch_geometric.loader import DataLoader
#import networkx as nx
import pathlib
import os
import numpy as np
from ast import literal_eval
import time

from torch_geometric.loader import DataLoader
from torch.nn import Linear
from torch.nn import MSELoss
import torch.nn.functional as F
from torch_geometric.nn import GCNConv
from torch_geometric.nn import global_mean_pool
from torch_geometric.nn import global_add_pool

import matplotlib.pyplot as plt
import random
import statistics


from torch.nn import Linear
from torch.nn import MSELoss
import torch.nn.functional as F
from torch_geometric.nn import GCNConv
from torch_geometric.nn import global_mean_pool
from torch_geometric.nn import global_add_pool

import time

start_time = time.time()

data_list_1 = [] #list to keep all Data structures
data_list_2 = [] 
data_list_3 = [] 
data_list_4 = [] 

# perform tasks to gpu if available 
#device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

# Get all design_* files from Dataset (root)

# Due to several issues, we heavily relied on absolute paths for our folders.
# Please correct them accordingly.

project = os.path.join(pathlib.Path().absolute(),'F:\\MyWork\\Dataset')
designs = os.listdir(project)
#print(project)


with open("out.txt","w") as f: print('useful stats for training\n',file=f) #  create a statistics file to dump information
with open("train_pred.txt","w") as f: print("",file=f)
with open("test_pred.txt","w") as f: print("",file=f)

with open("files.txt","w") as f: print('\n',file=f) 
count = 0

for d in designs:
    if 'design_' in d:
      dd = d + "\\Graphs\\"
      path = os.path.join(project,dd)

      with open(path +"..\\directives.tcl") as f:
         count = 0
         for line in f:
            count +=1
         if count == 23: #23 if date line exists
            graph_attr = torch.tensor(1, dtype=torch.float)
         else:
            #graph_attr = torch.tensor(0, dtype=torch.float)
            print(count)
            continue
            
      print(path)
      
      with open("files.txt","a") as f: print(f'{count}    {path}\n',file=f) 
      count +=1
      #data are loaded from the appropriate files as tensors in lists
   
      node_labels = []
      adj_matrix = []
      
      graph_labels = []
      graph_labels_d = []
      graph_labels_s = []
      graph_labels_h = []
      
      FU = []
      # Load node features -> x
      with open(path +"\\node_labels.txt") as f:
         for line in f:
             if "RTL" not in line:
                 node_labels.append(literal_eval(line))
             else:
                 continue
      #node_labels = torch.tensor(node_labels, dtype=torch.long)
            #FU.append((literal_eval(line))[2])
      node_labels = torch.tensor(node_labels, dtype=torch.float)


      # Load adjacency matrix -> edge index
      with open(path +"\\new_adj_matrix.txt") as f:
         for line in f:
            adj_matrix.append(literal_eval(line))
      adj_matrix = torch.tensor(adj_matrix, dtype=torch.long)
      adj_matrix = torch.transpose(adj_matrix,0,1)
      
      # # Load graph labels -> y, the graph labels
      if ga == 0:
          dd = d + "\\FI\\"
          path = os.path.join(project,dd)
          
          if not os.path.exists(path +"stats_2.txt"):
              os.rename(os.path.join(project,d), os.path.join(project,"remove",d))
              continue
          with open(path +"stats_2.txt") as f:
             l = f.readline()
             l = l.split(" = ")
             l = l[1].replace(' %\n','')
             graph_labels.append(float(l))
             
             l = f.readline()
             l = l.split(" = ")
             l = l[1].replace(' %\n','')
             graph_labels_d.append(float(l))
               
             l = f.readline()
             l = l.split(" = ")
             l = l[1].replace(' %\n','')
             graph_labels_s.append(float(l))
               
             l = f.readline()
             l = l.split(" = ")
             l = l[1].replace(' %\n','')
             graph_labels_h.append(float(l))
             
          graph_labels = torch.tensor(graph_labels, dtype=torch.float)
          graph_labels_d = torch.tensor(graph_labels_d, dtype=torch.float)
          graph_labels_s = torch.tensor(graph_labels_s, dtype=torch.float)
          graph_labels_h = torch.tensor(graph_labels_h, dtype=torch.float)
      else:
          # If 'ga' variable is not 1, we set a static graph label equal to 1. We use this to test the prediction mechanism.
          y = 1
          graph_labels = torch.tensor(y, dtype=torch.float)
          graph_labels_d = torch.tensor(y, dtype=torch.float)
          graph_labels_s = torch.tensor(y, dtype=torch.float)
          graph_labels_h = torch.tensor(y, dtype=torch.float)
          
              
      
      
      # Load graph labels -> y, our graph labels. for now we examine critical and detected
      # with open(path +"\\graph_labels_detected.txt") as f:
      #    for line in f:
      #       graph_labels.append(literal_eval(line))
      #       #global_graph_labels_d.append(literal_eval(line))
      # graph_labels = torch.tensor(graph_labels, dtype=torch.float)
            
      #create data instance, according to the following:
      # https://pytorch-geometric.readthedocs.io/en/latest/modules/data.html#torch_geometric.data.Data
      # x is the adjacency matrix
      # edge index is
      # node labels is
      # graph labels is y
      
      #IMPORTANT! node features are normalized.
      
      if max(max(adj_matrix[0]),max(adj_matrix[0]))+1 == node_labels.shape[0] and node_labels.shape[1] == 818:

         # Good practice : add 1e-9 to data prior to log transformation!!! (Data smoothing)
         data_1 = Data(F.normalize(node_labels), edge_index=adj_matrix, y=torch.log(graph_labels),intensity=graph_attr,d_index=d)
         #data_1 = Data(F.normalize(node_labels), edge_index=adj_matrix, y=torch.log(torch.tensor(1, dtype=torch.float)),intensity=graph_attr,d_index=d) # Set 1 to test prediction
         data_2 = Data(F.normalize(node_labels), edge_index=adj_matrix, y=graph_labels_d,intensity=graph_attr,d_index=d)
         data_3 = Data(F.normalize(node_labels), edge_index=adj_matrix, y=graph_labels_s,intensity=graph_attr,d_index=d)
         data_4 = Data(F.normalize(node_labels), edge_index=adj_matrix, y=graph_labels_h,intensity=graph_attr,d_index=d)  

         #append data to data_list
         data_list_1.append(data_1)
         data_list_2.append(data_2)
         data_list_3.append(data_3)
         data_list_4.append(data_4)
      
        
torch.save(data_list_1,"dataset_c_04_05.pt")
torch.save(data_list_2,"dataset_d__04_05.pt")
torch.save(data_list_3,"dataset_s_04_05.pt")
torch.save(data_list_4,"dataset_h_04_05.pt")

print("--- %s seconds ---" % (time.time() - start_time))


   