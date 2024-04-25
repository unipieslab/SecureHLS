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

import spydrnet as sdn
import networkx as nx

import numpy as np
from matplotlib import pyplot as plt
import pathlib
import os
from pprint import pprint

netlist = None
connectivity_graph = None

test = []

wire_names = []
module_names = []

def edif_read(edif_file):
    """
    This example loads a netlist and then generates two connectivity graphs: one with top level ports and one without.
    The connectivity graph without top level ports could be generated more quickly by copying the graph containing the
    ports and then removing the nodes that represent top level ports. These connectivity graphs can also be used to
    generate sequential connectivity graphs by removing nodes that represent combinational logic and propagating their
    created connections (add an edge from all predecessors to all successors).
    """
    global netlist
    global connectivity_graph
	
	#.edf to ir.netlist
    #netlist = sdn.load_example_netlist_by_name('b13')
    netlist = sdn.parse(edif_file)
    connectivity_graph_with_top_level_ports = get_connectivity_graph(include_top_ports=True)
    #print("Total nodes in connectivity_graph with top_level_ports",connectivity_graph_with_top_level_ports.number_of_nodes())
    #print("Total edges in connectivity_graph with top_level_ports",connectivity_graph_with_top_level_ports.number_of_edges())
    connectivity_graph_without_top_level_ports = get_connectivity_graph(include_top_ports=False)
    #print("Total nodes in connectivity_graph without top_level_ports",connectivity_graph_without_top_level_ports.number_of_nodes())
    #print("Total edges in connectivity_graph without top_level_ports",connectivity_graph_without_top_level_ports.number_of_edges())
		
	############################### MY CODE ###################################
        
    #RTL.append(node.item._data['.NAME'])
    #FU.append(node.item.reference.name)

    return connectivity_graph_with_top_level_ports  ## CHECK 
    #return connectivity_graph_without_top_level_ports
	
	###########################################################################
	
def get_connectivity_graph(include_top_ports = True):
    """
    This function generates the connectivity graph of the netlist.
    """
    connectivity_graph = nx.MultiDiGraph()
    
    #G=XGraph(selfloops=False, multiedges=False)
    
    top_instance_node = generate_nodes()

    leaf_instance_nodes = get_leaf_instance_nodes(top_instance_node)
    connectivity_graph.add_nodes_from(leaf_instance_nodes)
    
    top_port_nodes = []

    if include_top_ports:
        top_port_nodes = get_top_port_nodes(top_instance_node)
        connectivity_graph.add_nodes_from(top_port_nodes)

    for node in list(connectivity_graph.nodes):
        downstream_nodes = get_downstream_nodes(node, include_top_ports)
        for downstream_node in downstream_nodes:
           
        # delete the following block if if you want PI/O as nodes  
            if node in top_port_nodes:
               if node.item.direction.name == "IN":
                  #downstream_node.item._data['.NAME'] = downstream_node.item._data['.NAME']+" + "
                  downstream_node.item._data['EDIF.identifier'] = downstream_node.item._data['EDIF.identifier']+" + "
            elif downstream_node in top_port_nodes:
               if downstream_node.item.direction.name == "OUT":
                  #node.item._data['.NAME'] = node.item._data['.NAME']+" - "
                  node.item._data['EDIF.identifier'] = node.item._data['EDIF.identifier']+" - "
            else:
         ####################################################

               connectivity_graph.add_edge(node, downstream_node)
      
    # delete the following condition if you want PI/O as nodes  
    if include_top_ports:
       connectivity_graph.remove_nodes_from(top_port_nodes)

    return connectivity_graph

def generate_nodes():
    """
    This function generates a unique node for all instances of elements in a netlist.
    """
    top_node = Node(None, netlist.top_instance)
    #print('Top Node:',top_node)
    search_stack = [top_node]
    while search_stack:
        node = search_stack.pop()
        item = node.item
        if isinstance(item, sdn.Instance):
            #print('Node_instance:',node)
            #print(item.name)            
            ref = item.reference
            for port in ref.ports:
                new_node = Node(node, port)
                node.children[port] = new_node
                search_stack.append(new_node)
            for cable in ref.cables:
                new_node = Node(node, cable)
                node.children[cable] = new_node
                search_stack.append(new_node)
            for instance in ref.children:
                new_node = Node(node, instance)
                node.children[instance] = new_node
                search_stack.append(new_node)
        elif isinstance(item, sdn.Port):
            #print('Node_pin:',node)
            #print(item.name)
            for pin in item.pins:
                new_node = Node(node, pin)
                node.children[pin] = new_node
                search_stack.append(new_node)
        elif isinstance(item, sdn.Cable):
            for wire in item.wires:
                new_node = Node(node, wire)
                node.children[wire] = new_node
                search_stack.append(new_node)
    return top_node

def get_leaf_instance_nodes(top_instance_node):
    """
    This function returns all leaf instance nodes in a netlist.
    """
    leaf_instance_nodes = list()
    search_stack = [top_instance_node]
    while search_stack:
        current_node = search_stack.pop()
        if isinstance(current_node.item, sdn.Instance):
            if current_node.item.reference.is_leaf() and not((current_node.item.reference.name == "GND")or(current_node.item.reference.name == "VCC")):
                leaf_instance_nodes.append(current_node)
            else:
                search_stack += current_node.children.values()
    return leaf_instance_nodes

def get_top_port_nodes(top_instance_node):
    """
    This function returns top_level_ports in a netlist, (i.e., ports that belong to the top_instance if the netlist).
    """
    top_port_nodes = list(top_instance_node.children[x] for x in top_instance_node.children if (isinstance(x, sdn.Port) and not ((top_instance_node.item.name == "ap_clk") or (top_instance_node.item.name == "ap_rst"))))
    #print(top_port_nodes) #input and output
    return top_port_nodes

def get_downstream_nodes(node, include_top_ports):
    """
    This function finds downstream nodes (leaf instance and optionally top_level ports) from a given node. There are
    some involved traversals included in this function (going from an InnerPin to and OuterPin and visa-versa).
    """
    downstream_nodes = list()
    found_pin_nodes = set()
    search_stack = list()
    # Find starting wires if provided node is a leaf instance.
    if isinstance(node.item, sdn.Instance):
        instance = node.item
        #print(node) # current labeling!
		# Not here!
        #RTL.append(node.item._data['.NAME'])
        #FU.append(node.item.reference.name)
		# ---
        #print(instance.reference.references) 
        parent_instance = node.parent
        #print(node.parent.get_hiearchical_name())
        if node.parent.get_hiearchical_name() not in module_names:
           module_names.append(node.parent.get_hiearchical_name())
        for pin in instance.pins:
            inner_pin = pin.inner_pin
            wire = pin.wire
            
            if inner_pin.port.direction in {sdn.OUT, sdn.INOUT} and wire:
                port_node = node.children[inner_pin.port]
                pin_node = port_node.children[inner_pin]
                found_pin_nodes.add(pin_node)

                cable = wire.cable
                
                #print(wire.cable.name)
                #print(len(wire.cable.wires))
                name = str(node.parent.get_hiearchical_name()) + "/" + str(wire.cable.name)
                
                lsb = 0
                if len(wire.cable.wires) > 1:
                   msb = len(wire.cable.wires) - 1
                   name = name + " ["+ str(msb)+":"+str(lsb)+"]"
                   
                   #print(name)
                   wire_names.append(name)
                   break
                else:
                   #print(name)
                   wire_names.append(name)
                   
                cable_node = parent_instance.children[cable]
                wire_node = cable_node.children[wire]
                search_stack.append(wire_node)
    # Find starting wires if provided node is a top_level_port and include_top_ports is asserted.
    elif include_top_ports and isinstance(node.item, sdn.Port):
        port = node.item
        parent_instance = node.parent

        if port.direction in {sdn.IN, sdn.INOUT}:
            for pin in port.pins:
                wire = pin.wire
                if wire:
                    pin_node = node.children[pin]
                    found_pin_nodes.add(pin_node)

                    cable = wire.cable
                    cable_node = parent_instance.children[cable]
                    wire_node = cable_node.children[wire]
                    
                    search_stack.append(wire_node) #REMOVES WIRING FROM PRIMARY PORTS TO NODES
                    
    # Perform a non-recursive traversal of identified wires until all leaf instances (and optionally top_level_ports)
    # are found.
    while search_stack:
        current_wire_node = search_stack.pop()
        current_cable_node = current_wire_node.parent
        current_instance_node = current_cable_node.parent

        current_wire = current_wire_node.item
        for pin in current_wire.pins:
            if isinstance(pin, sdn.InnerPin):
                port = pin.port
                port_node = current_instance_node.children[port]
                pin_node = port_node.children[pin]
                if pin_node not in found_pin_nodes:
                    found_pin_nodes.add(pin_node)
                    current_instance_parent_node = current_instance_node.parent
                    if current_instance_parent_node:
                        outer_pin = current_instance_node.item.pins[pin]
                        wire = outer_pin.wire
                        if wire:
                            cable = wire.cable
                            cable_node = current_instance_parent_node.children[cable]
                            wire_node = cable_node.children[wire]
                            search_stack.append(wire_node)
                    elif include_top_ports:
                        downstream_nodes.append(port_node)
            elif isinstance(pin, sdn.OuterPin):
                instance = pin.instance
                instance_node = current_instance_node.children[instance]
                if instance.reference.is_leaf():
                    downstream_nodes.append(instance_node)
                else:
                    inner_pin = pin.inner_pin
                    port = inner_pin.port
                    port_node = instance_node.children[port]
                    pin_node = port_node.children[inner_pin]
                    found_pin_nodes.add(pin_node)

                    wire = inner_pin.wire
                    if wire:
                        cable = wire.cable
                        cable_node = instance_node.children[cable]
                        wire_node = cable_node.children[wire]
                        search_stack.append(wire_node)

    return downstream_nodes

class Node:
    def __init__(self, parent, item):
        self.parent = parent
        self.item = item
        self.children = dict()

    def get_hiearchical_name(self):
        parents = list()
        parent = self.parent
        while parent:
            parents.append(parent)
            parent = parent.parent
        prefix = '/'.join(x.get_name() for x in reversed(parents))
        if isinstance(self.item, sdn.Wire):
            return "{}[{}]".format(prefix, self.item.cable.wires.index(self.item))
        elif isinstance(self.item, sdn.Pin):
            return "{}[{}]".format(prefix, self.item.port.pins.index(self.item))
        else:
            if prefix:
                return "{}/{}".format(prefix, self.get_name())
            else:
                return self.get_name()

    def get_name(self):
        if 'EDIF.original_identifier' in self.item:
            return self.item['EDIF.original_identifier']
        elif 'EDIF.identifier' in self.item:
            return self.item['EDIF.identifier']


# Get all design_* files

project = os.path.join(pathlib.Path().absolute(),'Designs\\')
designs = os.listdir(project)
#print(project)

for d in designs:
    if 'design_' in d:
      d = d + "\\Graphs\\"
      path = os.path.join(project,d)
      edif_file = path + "design.edf"
      

      #For each of those files, do:
      
      # Generate graph
      G = edif_read(edif_file)
      
      # Remove self-loops from graph
      G.remove_edges_from(nx.selfloop_edges(G))
      
      # Rename nodes with the RTL nam assigned in netlist
      
      RTL_obj= list(G.nodes._nodes)
      
      s = len(RTL_obj)
      
      node_id = []
      node_FU = []
      #node_ports = []
      
      for i in range(s):
          node_id.append(RTL_obj[i].get_hiearchical_name())
          #node_id.append(RTL_obj[i].get_name())
          if hasattr(RTL_obj[i].item,'reference'):
             node_FU.append(RTL_obj[i].item.reference.name)
             
         # if you still want to indicate primary I/O as nodes use the code below
         # it will assign a fake functional unit for the node           
         # GO TO for node in list(connectivity_graph.nodes): FIRST!!!
         
         # remove the conditions to 
         
         
         # else:
         #    if RTL_obj[i].item.direction.name == "OUT":
               
         #       #delete edge but keep dest node
               
         #       #delete node
               
         #       #add attr to dest node
               
         #       node_FU.append("PO")
         #    elif RTL_obj[i].item.direction.name == "IN":
               
         #       node_FU.append("PI")
          #node_ports.append(RTL_obj[i].item.pins)
      
      # Make the node names more readable
      N = nx.relabel_nodes(G, dict(zip(G.nodes(),node_id)))
      
      # Draw graph
      #nx.draw_networkx(N)
      
      # Get adjacency matrix
      A = nx.adjacency_matrix(G)
      
      # Write the adjacency matrix in a file
      text_path = path + "adj_matrix.txt"
      file = open(text_path,'w')
      
      for i in range(A.shape[0]):
          for j in range(A.shape[1]):
              file.write(str(i)+' ' +str(j)+' '+str(A[i,j])+'\n')
      file.close()
      
      
      # Write the adjacency matrix in a file
      text_path = path + "module_names.txt"
      file = open(text_path,'w')
      
      for i in module_names:
              file.write(str(i)+'\n')
      file.close()
      
      
      # Write the node id (as appearing in Vivado) in a file
      text_path = path + "node_id.txt"
      file = open(text_path,'w')
      
      for i in node_id:
              file.write(str(i)+'\n')
      file.close()
      
      # Write the wire names in a file
      text_path = path + "wire_names.txt"
      file = open(text_path,'w')
      
      for i in wire_names:
              file.write(str(i)+'\n')
      file.close()
      
      # Write the resource corresponding to each node in a file
      text_path = path + "node_FU.txt"
      file = open(text_path,'w')
      
      for i in node_FU:
              file.write(str(i)+'\n')
      file.close()
      
