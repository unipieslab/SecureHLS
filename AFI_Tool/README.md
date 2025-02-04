# AFI_Tool - Automated Fault Injection Flow

The aim of this tool is to evaluate the fault-tolerance aspect of designs generated using Vivado HLS tool. Vivado HLS allows the automatic generation of multiple functionally equivalent, but architecturally different designs using a single high-level code, describing the desired functionality. After the synthesis of their corresponding RTL netlist, the FI simulations are performed.

An example design is located in this project.

## Prerequisites

The folder AFI_Tool contains all the files required for the use of the tool. In order for the flow to be operational, the following tools need to be present at the user’s machine: 
* Vivado HLS 2020.1 
* Vivado 2020.1
* Matlab 2021.b
* Git Bash
* Python 3.7
  - [SPYDRNET framework](https://github.com/byuccl/spydrnet) 


## Flow
The flow starts by executing one of the following  scripts: 
run.cmd allows users to perform a selected FI attack scenario. 
run_all.cmd executed all the available FI attack scenarios. 

## Available Scenarios:
* _Exhaustive Single-bit flip FI Simulation_: Injection of a single bit flip to every register extracted from RTL netlist, at a specific clock cycle of the designs’ execution, for all valid clock cycles. Its duration lasts a clock cycle, simulating a transient bit-flip.

* _Statistical Multi-bit flip (MBF) – Multiplicities of 2, 3, 4 and 5_: Those scenarios assume multiple single-bit flips are injected in a design at the same clock cycle. Our flow considers 2, 3, 4 or 5 concurrent fault injections.  As the exhaustive examination of all possible bit flips combinations can be extremely time-consuming, the statistical method is instead used. For this, a representative subset of the signals active at a specific time step is selected to derive conclusions about the designs’ behavior against the specific fault model. The subset is randomly generated, and its size is determined by the set error margin. Lower error margins approximate the actual behavior of the design against the fault model better, yet the signal subset and in extend the time required for the execution of the FI attack grows exponentially. The error margin value can be defined from the ERROR_MARGIN.txt file inside Constants folder. Other values, such as the confidence (99%) or p-value (0.5) are hardcoded in generateFaultPairs.m script and need to be modified manually if there is such a requirement. Again, their duration is of one clock cycle (transient bit-flips).

* An additional fault model is included, regarding the examination of _cone partitioning_. This particular model can only be applied to the flip-flops located in a specific part of the RTL design, simulating a targeted laser attack. These results can be representative even after the composition stage if the specific elements enclosed within the partitioning cone are still interconnected (functionally) with each other. The cone partitioning model focuses on fault injection into the flip-flops of a circuit. Each cone consists of a flip-flop which is the starting point (peak) of the cone and extends backwards. Essentially, a partitioning cone is defined, from the outputs to the inputs, by the et of all nets, combinatorial nodes and primary inputs that are interconnected at the input of a flip flop. Within this, all elements enclosed within the partitioning cone are taken into account. The partitioning cone extends to the point where another flip-flop or a primary input is encountered.

## Attack Scenarios Operation
For any FI attack scenario, an execution without faults (gold) is performed in order to derive the intended behavior of the design, both for verification reasons as well as the subsequent comparison with the FI campaign results. The verification can be performed by reviewing the gold_run.txt file inside the FI folder for each design. Additionally, the execution time of the design is defined here, by monitoring the behavior of the /top_function/ap_done signal. During the attack, the name of the signal/signal set for higher multiplicities as well as clock cycle under attack will appear. The results are dynamically written at out.txt (or Mx_out.txt, if a multi-bit FI is performed) file.
After the finalization of the FI attacks for all designs, the fault_evaluation.m script is executed. The script parses the gold_run.txt and out.txt. It compares the outputs of a non-faulty execution in gold_run.txt to the outputs derived for each fault injection in out.txt. From that comparison, four categorizations are derived:

* _Silent errors_: The output of an execution where a FI was performed is the same as the correct (gold) output. Thereby, the fault had no observable effect on the design.
* _Hang errors_: The top_function/ap_done signal was affected by the FI attack. It is an indication that the control logic of the design (i.e its state machine) was affected. In that case, the output value, regardless it being correct or not, is not valid.
* _Critical errors_: The output of an execution is erroneous (differs from the gold output).
A special case is also considered:
* _Detected errors_: This categorization can be used if the design contains a detection mechanism (we assume the design under consideration generates two outputs). For example, if the design implements a Double Modular Redundancy (DMR) countermeasure, where two outputs are extracted, a detected fault is one that has affected the two modules in a different manner. This case assumes that the FI has affected the outputs in a different manner.

Note: The Detected errors examination is by default enabled, as the flow was used for the examination of DMR-enhanced designs. The relevant code in fault_evaluation.m should be disabled if the user targets a non-DMR design.

For each design, sbf_stats.txt file (or Mx_stats.txt, if a multi-bit FI is performed) is generated inside the respective FI folder. There, the raw numbers of faults per category, as well as the error rates have been saved.
All flow processes are logged to log.txt file to help the user monitor the operation of the tool.
