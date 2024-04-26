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

# Important : Due to extensive absolute path usage, the paths included are corrupted. The code needs modification, but the core functionality (prediction) is correct

flag_cuda = 1
ff = "4"  #This is the best model index. Derived after examining the test_val.txt for each value.

import torch
from torch_geometric.data import Data
from torch_geometric.data import InMemoryDataset
from torch_geometric.loader import DataLoader
#import networkx as nx
import pathlib
import os
import random
import numpy as np
import matplotlib.pyplot as plt
from ast import literal_eval

from torch_geometric.loader import DataLoader
from torch.nn import Linear
from torch.nn import MSELoss
import torch.nn.functional as F
from torch_geometric.nn import GCNConv
from torch_geometric.nn import GATConv
from torch_geometric.nn import GAT
from torch_geometric.nn import global_mean_pool
from torch_geometric.nn import global_add_pool
from torch_geometric.nn import global_max_pool
from torch.optim.lr_scheduler import ReduceLROnPlateau
import time

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

dataset = [] #list to keep all Data structures
train_dataset = []
val_dataset = []

d = #set a .pt file to for error rate prediction#
dataset = torch.load(d,map_location='cuda')

with open("..\\val_log_pred.txt","w") as f: 
    print("\n",file=f)
with open("..\\val_pred.txt","w") as f: 
    print("\n",file=f)

##############################################################################
for i in range(len(dataset)):
    mean = dataset[i].x.mean(1, keepdim=True)
    deviation = dataset[i].x.std(1, keepdim=True)
    dataset[i].x = (dataset[i].x - mean) / deviation

###############################################################################

val_loader = DataLoader(dataset, batch_size=1)

class GCN(torch.nn.Module):
    def __init__(self, hidden_channels):
        super(GCN, self).__init__()
        torch.manual_seed(12345)
        self.conv1 = GCNConv(818, hidden_channels)
        self.conv2 = GCNConv(hidden_channels, hidden_channels)
        self.conv3 = GCNConv(hidden_channels, hidden_channels)

        
        #self.lin = Linear(hidden_channels, dataset.num_classes)
        self.lin = Linear(hidden_channels, 1)

    def forward(self, x, edge_index, batch):
        # 1. Obtain node embeddings 
        x = self.conv1(x, edge_index)
        x = x.relu()
        x = self.conv2(x, edge_index)
        x = x.relu()
        x = self.conv3(x, edge_index)

        # 2. Readout layer
        x = global_max_pool(x, batch)  # [batch_size, hidden_channels]

        # 3. Apply a final classifier
        #sx = F.dropout(x, p=0.5, training=self.training)
        x = self.lin(x)
        
        return x


device = torch.device("cuda")
model = GCN(hidden_channels=128)
model.load_state_dict(torch.load(".pth",map_location='cuda')) # Set your trained model here
model.to(device)


criterion = torch.nn.MSELoss()
if (flag_cuda):
    model = model.cuda()
    criterion = criterion.cuda()
print(model)

def val(loader):     
    
    with torch.no_grad():
        test_loss = 0
        exp_test_loss = 0
        total_error = 0
        
        
        model.eval()
        
        for data in loader:  # Iterate in batches over the training/test dataset.
            print(data.d_index)
                
            start_time = time.time()
       
            out = model(data.x, data.edge_index, data.batch) 
            #print("--- %s seconds ---" % (time.time() - start_time))
            
            
            design,x = data.d_index[0].split("_")
            
            output_file_path = os.path.join("..\\design_"+x+"\\critical_prediction.txt") # A .txt file with the predicted value is going to be generated inside the design_x file
            with open(output_file_path,"w") as f: f.write(str(float(torch.exp(out.data))))
            
            output_file_path = os.path.join("..\\design_"+x+"\\critical_gt.txt") # A .txt file with the ground truth value is going to be generated inside the design_x file
            with open(output_file_path,"w") as f: f.write(str(float(torch.exp(data.y))))
                
            loss = criterion(out, data.y)  # Compute the loss.
            exp_loss = criterion(torch.exp(out), torch.exp(data.y))  # Compute the loss.
            
            
            with open("..\\val_log_pred.txt","a") as f: 
                print(str(data.d_index)+"   Prediction: "+str(float(out.data))+" Ground Truth: "+str(float(data.y))+" MSE: "+str(loss.item())+"\n",file=f)
            with open("..\\val_pred.txt","a") as f: 
                print(str(data.d_index)+"   Prediction: "+str(float(torch.exp(out.data)))+" Ground Truth: "+str(float(torch.exp(data.y)))+" MSE: "+str(loss.item())+"\n",file=f)
            
            test_loss += loss.item()
            
            exp_test_loss += exp_loss.item()
        
            #total_error += (torch.exp(out) - torch.exp(data.y)).abs().sum().item()
                       
        # Test Loss, Train Accuracy, Test Accuracy 
    return test_loss/len(loader.dataset),exp_test_loss/len(loader.dataset)


val_epoch_loss, exp_val_epoch_loss = val(val_loader)
del model

