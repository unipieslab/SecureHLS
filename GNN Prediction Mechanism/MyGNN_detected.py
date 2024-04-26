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


flag_cuda = 1

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
from torch_geometric.nn import GATConv
from torch_geometric.nn import GCNConv
from torch_geometric.nn import GAT
from torch_geometric.nn import global_mean_pool
from torch_geometric.nn import global_add_pool
from torch_geometric.nn import global_max_pool
from torch.optim.lr_scheduler import ReduceLROnPlateau
import time

start_time = time.time()

fold_score = [0,0,0,0,0]


with open("..\\kfold_detected\\out.txt","w") as f: print("",file=f) #  create a statistics file to dump information

with open("..\\kfold_detected\\train_pred.txt","w") as f: print("",file=f)
with open("..\\kfold_detected\\val_pred.txt","w") as f: print("",file=f)
with open("..\\kfold_detected\\val_log_pred.txt","w") as f: print("",file=f)
with open("..\\kfold_detected\\test_pred.txt","w") as f: print("",file=f)

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')


dataset = [] #list to keep all Data structures
train_dataset = []
val_dataset = []

train_loss = []    #lists to append the metric values
val_loss = []
exp_val_loss = []

val_error = []
test_error = []

global_graph_labels = []
global_graph_labels_d = []

dataset = torch.load("dataset_d_04_05.pt",map_location='cuda')

##############################################################################
for i in range(len(dataset)):
    mean = dataset[i].x.mean(1, keepdim=True)
    deviation = dataset[i].x.std(1, keepdim=True)
    dataset[i].x = (dataset[i].x - mean) / deviation
   
new_dataset = []

index = []
idx = 0

for i in range(len(dataset)):
      index.append(idx)
      idx += 1

# shuffle dataset
random.shuffle(dataset)

  
# Reserve a 10% for test
split = int(len(dataset)*0.9)
train_dataset = dataset[:split]
test_dataset = dataset[split:]

test_loader = DataLoader(test_dataset, batch_size=1)

###############################################################################
# Reserve a 20% for test
split = int(len(train_dataset)*0.8)
train_dataset = dataset[:split]
val_dataset = dataset[split:]

val_loader = DataLoader(val_dataset, batch_size=1)
###############################################################################

s1 = int(len(train_dataset)*0.2)
s2 = int(len(train_dataset)*0.4)
s3 = int(len(train_dataset)*0.6)
s4 = int(len(train_dataset)*0.8)

train_2 = DataLoader(train_dataset[:100], batch_size=1)
val_2 = val_loader

train_3 = DataLoader(train_dataset[:200], batch_size=1)
val_3 = val_loader

train_4 = DataLoader(train_dataset[:500], batch_size=1)
val_4 = val_loader

train_5 = DataLoader(train_dataset[:750], batch_size=1)
val_5 = val_loader

train_1 = DataLoader(train_dataset[:50], batch_size=1)
val_1 = val_loader

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

train_loader = [train_1,train_2,train_3,train_4,train_5]
val_loader = [val_1,val_2,val_3,val_4,val_5]

for fold in range(5):
    
    model = GCN(hidden_channels=128)

    # We swap the loss function (originally used for classification paradigm) for MSE, as suggested for regression problems
    # MSE = average of the squares of the errors of all the data points in the given dataset

    criterion = torch.nn.MSELoss()
    if (flag_cuda):
       model = model.cuda()
       criterion = criterion.cuda()
    print(model)
    
    #########################################
    model_best = GCN(hidden_channels=128)

    if (flag_cuda):
       model_best = model_best.cuda()
    #########################################
    optimizer = torch.optim.Adam(model.parameters(), lr= 0.01,weight_decay=1e-5)#L2 regularization
    scheduler = ReduceLROnPlateau(optimizer, mode='min', factor=0.1, patience=10, min_lr=1e-6)
    
    class EarlyStopper:
        def __init__(self, patience=1, min_delta=0):
            self.patience = patience
            self.min_delta = min_delta
            self.counter = 0
            self.min_validation_loss = np.inf
        
        def early_stop(self, validation_loss):
            if validation_loss < self.min_validation_loss:
                self.min_validation_loss = validation_loss
                self.counter = 0
                torch.save(model.state_dict(),"..\\kfold_detected\\model_kfold_detected_"+str(fold)+".pth")
                fold_score[fold] = validation_loss
            elif validation_loss > (self.min_validation_loss + self.min_delta) :
                self.counter += 1
                if self.counter >= self.patience:
                    return True
            return False 
    with open("..\\kfold_detected\\out.txt","a") as f: 
        print("--- Fold %d ---",fold,file=f)
    with open("..\\kfold_detected\\train_pred.txt","a") as f: 
        print("--- Fold %d ---",fold,file=f)
    with open("..\\kfold_detected\\val_pred.txt","a") as f: 
        print("--- Fold %d ---",fold,file=f)
    with open("..\\kfold_detected\\val_log_pred.txt","a") as f: 
        print("--- Fold %d ---",fold,file=f)
    
    def train():
       
       i = 0
       
       t_loss = 0 #train_loss is set globally, this is a local variable
      
       model.train()
       for data in train_loader[fold]:  # Iterate in batches over the training dataset.
          #print(data.d_index)
          out = model(data.x, data.edge_index, data.batch)  # Perform a single forward pass.
          loss = criterion(out, data.y)  # Compute the loss.
          
          with open("..\\kfold_detected\\train_pred.txt","a") as f: print("   Prediction: "+str(float(torch.exp(out.data)))+" Ground Truth: "+str(float(torch.exp(data.y)))+"\n",file=f)
          
          loss.backward()  # Derive gradients.
          optimizer.step()  # Update parameters (weights) based on gradients.
          optimizer.zero_grad()  # Clear gradients.         
        
          t_loss += loss.item()
          
          random.shuffle(train_loader[fold].dataset)

       return t_loss/len(train_loader[fold].dataset)

    def val(loader):     
        with torch.no_grad():
            test_loss = 0
            exp_test_loss = 0
            total_error = 0
             
            model.eval()
            
            for data in loader:  # Iterate in batches over the training/test dataset.
                out = model(data.x, data.edge_index, data.batch) 
                loss = criterion(out, data.y)  # Compute the loss.
                exp_loss = criterion(torch.exp(out), torch.exp(data.y))  # Compute the loss.
                
                with open("..\\kfold_detected\\val_log_pred.txt","a") as f: print(str(data.d_index)+"   Prediction: "+str(float(out.data))+" Ground Truth: "+str(float(data.y))+"\n",file=f)
                with open("..\\kfold_detected\\val_pred.txt","a") as f: print(str(data.d_index)+"   Prediction: "+str(float(torch.exp(out.data)))+" Ground Truth: "+str(float(torch.exp(data.y)))+"\n",file=f)
                
                
                test_loss += loss.item()
                
                exp_test_loss += exp_loss.item()
            
                #total_error += (torch.exp(out) - torch.exp(data.y)).abs().sum().item()
                       
        # Test Loss, Train Accuracy, Test AccuracyS 
        return test_loss/len(loader.dataset),exp_test_loss/len(loader.dataset)

    def test(loader):     
          with torch.no_grad():
              test_loss = 0
              total_error = 0
         
              
         
              model_best.eval()

              for data in loader:  # Iterate in batches over the training/test dataset.
                  if (flag_cuda):
                    data = data.cuda()
                  out = model_best(data.x, data.edge_index, data.batch) 
                  loss = criterion(out, data.y)  # Compute the loss.
             
                  with open("..\\kfold_detected\\test_pred.txt","a") as f: print(str(data.d_index)+"   Prediction: "+str(float(torch.exp(out.data)))+" Ground Truth: "+str(float(torch.exp(data.y)))+"\n",file=f)
             
                  test_loss += loss.item()
         
                  total_error += (out - data.y).abs().sum().item()
                    
              # Test Loss, Train Accuracy, Test AccuracyS 
              return test_loss/len(loader.dataset), total_error / len(loader.dataset)

    
    early_stopper = EarlyStopper(patience=100)
    print(f'\nFold:{fold:02d}\n')
    for epoch in range(1, 1001):  
        
        
           
        with open("..\\kfold_detected\\train_pred.txt","a") as f: print(f'\nEpoch:{epoch:02d}\n',file=f)
        with open("..\\kfold_detected\\val_pred.txt","a") as f: print(f'\nEpoch:{epoch:02d}\n',file=f)
        with open("..\\kfold_detected\\val_log_pred.txt","a") as f: print(f'\nEpoch:{epoch:02d}\n',file=f)
        
        star = time.time()

    
        train_epoch_loss = train()
        
        val_epoch_loss, exp_val_epoch_loss = val(val_loader[fold])
        #test_loss,test_mae = test(test_loader)
        
        scheduler.step(val_epoch_loss)
        
        end = time.time()
        print(end - star)
        
        print(f'Epoch: {epoch:02d} | Loss: {train_epoch_loss:.4f} | Val Loss: {val_epoch_loss:.4f}')
        with open("..\\kfold_detected\\out.txt","a") as f: 
            print(f'Epoch: {epoch:02d} | Train Loss: {train_epoch_loss:.4f} | Val Loss: {val_epoch_loss:.4f}\n',file=f)
        
        train_loss.append(train_epoch_loss)
        val_loss.append(val_epoch_loss)
        #val_error.append(val_mae)
        #test_error.append(test_mae)
        
        if early_stopper.early_stop(val_epoch_loss):             
            break
        
    del model   
    
       
    model_best.load_state_dict(torch.load("..\\kfold_detected\\model_kfold_detected_"+str(fold)+".pth",map_location='cuda'))
    
    
    test_loss,test_mae = test(test_loader)
    with open("..\\kfold_detected\\test_pred.txt","a") as f: 
        print("--- Test MSE for fold "+str(fold)+" : "+str(test_mae)+"  ---",file=f)
    
    #torch.save(model,"model_kfold_detected_"+str(fold)+".pth")
    del model_best
    # figure, axis = plt.subplots(1, 2)
    # axis[0].set_title("Loss")
    # axis[0].plot(train_loss, 'bo-', label='train')
    # #axis[0].plot(total_test_loss, 'ro-', label='test')
    
    # axis[1].set_title("Error")
    # axis[1].plot(val_loss, 'go-', label='val')
    # #axis[1].plot(test_error, 'ro-', label='test')
    
    # plt.show()

index = fold_score.index(min(fold_score))


with open("..\\kfold_detected\\out.txt","a") as f: 
    print("--- %s seconds ---" % (time.time() - start_time),file=f)
