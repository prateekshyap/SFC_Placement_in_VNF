clear all
close all
clc

import java.util.TreeMap;
import java.util.ArrayList;
import java.util.LinkedList;

%% First Sample Network
% General Information:
% ---------------------
% 1)6 Physical Nodes
%	1: highest power but lesser cores
%	2, 3, 5: mid power and mid cores
%	4, 6: lowest power but more cores
% 2)3 types of VMs with 13 instances
%	1: can host upto 4 VNFs
%	2, 3, 4, 5, 9, 10: can host upto 2 VNFs
%	6, 7, 8, 11, 12, 13: can host only 1 VNF
% 3)8 VNFs with 22 instances
%	2, 7, 8: 2 instances
%	1, 3, 5, 6: 3 instances
%	4: 4 instances

%% Constants and Variables

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fileID = fopen('input/sample1/constants.txt','r');
formatSpecifier = '%f';
dimension = [1,9];

constants = fscanf(fileID,formatSpecifier,dimension);

N = constants(1,1); %Number of nodes in the physical network
V = constants(1,2); %Types of VMs being considered
VI = 0; %Total number of VM instances
F = constants(1,3); %Types of VNFs being considered
FI = 0; %Total number of VNF instances
S = constants(1,4); %Total number of SFCs
medium = constants(1,5); %Inverted Velocity depending on the transmission medium

% Failure Probabilities
rhoNode = constants(1,6); %Failure probability of nodes
rhoVm = constants(1,7); %Failure probability of VMs
rhoVnf = constants(1,8); %Failure probability of VNFs
L = constants(1,9); %Packet size
possibleCores = [1 2 4 6 8 10]; %Possible physical nodes

fileID = fopen('input/sample1/network.txt','r');
formatSpecifier = '%f';
dimension = [N,N];

sampleNetwork1Original = fscanf(fileID,formatSpecifier,dimension); %Physical network

[sampleNetwork1,nextHop] = allPairShortestPath(N,sampleNetwork1Original); %Floyd-Warshall

fileID = fopen('input/sample1/bandwidth.txt','r');
formatSpecifier = '%f';
dimension = [N,N];
bandwidths = fscanf(fileID,formatSpecifier,dimension); %Bandwidths of physical links
% Network Status
% nodes = [1 2 2 3 2 3];
% colors = ["aquamarine4","chocolate4","darkslategray3","bisque4","coral2","darkkhaki","gold3","firebrick","deepskyblue3","antiquewhite3","azure3","darkgoldenrod3"];
% nodeTypes = [1 3 2];
% vmTypes = [1 6 6];
% vnfInstanceCounts = [3 2 3 4 3 3 2 2];
% vnfServiceRates = [1 2 3 1 2 3 2 1];

fileID = fopen('input/sample1/nodeTypes.txt','r');
formatSpecifier = '%d';
dimension = [1,N];
nodeStatus = fscanf(fileID,formatSpecifier,dimension); %Type of nodes indicating the number of cores

fileID = fopen('input/sample1/vmTypes.txt','r');
formatSpecifier = '%d';
dimension = [V,2];
temp = fscanf(fileID,formatSpecifier,dimension); %Type of VMs and their requirements
vmTypes = temp(1:V,1)';
vmCoreRequirements = temp(1:V,2)';
VI = sum(vmTypes);

fileID = fopen('input/sample1/vnfTypes.txt','r');
formatSpecifier = '%d';
dimension = [1,F];
vnfTypes = fscanf(fileID,formatSpecifier,dimension); %Type of VNFs and their requirements
FI = sum(vnfTypes);

% vms = [1 2 2 2 2 3 3 3 2 2 3 3 3];
fileID = fopen('input/sample1/vms.txt','r');
formatSpecifier = '%d';
dimension = [1,VI];
vmStatus = fscanf(fileID,formatSpecifier,dimension); %Type of VM instances

% vnfs = [2 3 2 1 2 2 3 2 2 2 3 2 1 2 3 1 2 3 1 2 2 3];
fileID = fopen('input/sample1/vnfs.txt','r');
formatSpecifier = '%d';
dimension = [1,FI];
vnfStatus = fscanf(fileID,formatSpecifier,dimension); %Types of VNF instances

% sfcLengths = [3 3 4 2 3];
fileID = fopen('input/sample1/sfcLengths.txt','r');
formatSpecifier = '%d';
dimension = [1,S];
sfcLengths = fscanf(fileID,formatSpecifier,dimension); %

% Cost of hosting VMs on Physical Nodes
% Cv = [	1	2	4];
fileID = fopen('input/sample1/costVN.txt','r');
formatSpecifier = '%f';
dimension = [1,V];
Cv = fscanf(fileID,formatSpecifier,dimension); %Cost of hosting VMs on Nodes

% Cost of deploying VNFs on VMs
% Cf = [	4	2	1];
fileID = fopen('input/sample1/costFV.txt','r');
formatSpecifier = '%f';
dimension = [1,F];
Cf = fscanf(fileID,formatSpecifier,dimension); %Cost of deploying VNFs on VMs

% Failure level
iota = 0;

% Binary Variables
X = 0;

% VM to Physical Node matrix --- to be generated
% 		1	2	3	4	5	6
Xvn = [ 
		1	0	0	0	0	0; %1
		0	1	0	0	0	0; %2
		0	1	0	0	0	0; %3
		0	0	1	0	0	0; %4
		0	0	1	0	0	0; %5
		0	0	0	1	0	0; %6
		0	0	0	1	0	0; %7
		0	0	0	1	0	0; %8
		0	0	0	0	1	0; %9
		0	0	0	0	1	0; %10
		0	0	0	0	0	1; %11
		0	0	0	0	0	1; %12
		0	0	0	0	0	1 %13
	];

% %% VM hosting on the network
% XvnGen = zeros(sum(vmTypes),N);
% totalAvailableCores = sum(nodeStatus);
% totalRequiredCores = 0;
% for v = 1 : V
%     totalRequiredCores = totalRequiredCores+vmTypes(1,v)*vmCoreRequirements(1,v);
% end
% if totalRequiredCores > totalAvailableCores
%     fprintf('All VMs cannot be hosted');
% end
% coreCount = TreeMap();
% for c = 1 : 10
% 	coreCount.put(c,ArrayList());
% end
% for c = 1 : N
% 	coreCount.get(nodeStatus(1,c)).add(c);
% end
% vmStatus = zeros(1,VI);
% vmIndex = 1;
% for v = 1 : V
% 	instanceCount = vmTypes(1,v); %required number of instances
% 	requiredCores = vmCoreRequirements(1,v); %required number of cores
% 	for i = 1 : instanceCount
% 		currentCore = requiredCores;
% 		while (currentCore <= 10)
% 			availableMachines = coreCount.get(currentCore);
% 			if availableMachines.size() == 0
% 				if currentCore == 10
% 					currentCore = 11;
% 				else
% 					currentCore = coreCount.higherEntry(currentCore).getKey();
% 				end
% 			else
% 				machine = availableMachines.get(0);
% 				availableMachines.remove(0);
% 				XvnGen(vmIndex,machine) = 1;
% 				vmStatus(1,vmIndex) = v;
% 				machineCores = currentCore;
% 				machineCores = machineCores-requiredCores;
% 				if machineCores > 0
%                     coreCount.get(machineCores).add(machine);
%                 end
% 				vmIndex = vmIndex+1;
% 				break;
% 			end
% 		end
%     end
% end
% Xvn = XvnGen


% Function to VM map --- to be generated
% 		1 	2 	3 	4	5 	6	7	8	9	10	11	12	13
Xfv = [ 
		0	0	0	1	0	0	0	0	0	0	0	0	0; %1_1
		0	0	0	0	0	0	1	0	0	0	0	0	0; %1_2
		0	0	0	0	0	0	0	0	1	0	0	0	0; %1_3
		1	0	0	0	0	0	0	0	0	0	0	0	0; %2_1
		0	1	0	0	0	0	0	0	0	0	0	0	0; %2_2
		0	0	0	0	1	0	0	0	0	0	0	0	0; %3_1
		0	0	0	0	0	0	0	1	0	0	0	0	0; %3_2
		0	0	0	0	0	0	0	0	0	1	0	0	0; %3_3
		0	0	1	0	0	0	0	0	0	0	0	0	0; %4_1
		0	0	0	1	0	0	0	0	0	0	0	0	0; %4_2
		0	0	0	0	0	1	0	0	0	0	0	0	0; %4_3
		0	0	0	0	0	0	0	0	1	0	0	0	0; %4_4
		1	0	0	0	0	0	0	0	0	0	0	0	0; %5_1
		0	0	0	0	0	0	0	0	0	1	0	0	0; %5_2
		0	0	0	0	0	0	0	0	0	0	0	1	0; %5_3
		1	0	0	0	0	0	0	0	0	0	0	0	0; %6_1
		0	0	0	0	1	0	0	0	0	0	0	0	0; %6_2
		0	0	0	0	0	0	0	0	0	0	0	0	1; %6_3
		1	0	0	0	0	0	0	0	0	0	0	0	0; %7_1
		0	0	1	0	0	0	0	0	0	0	0	0	0; %7_2
		0	1	0	0	0	0	0	0	0	0	0	0	0; %8_1
		0	0	0	0	0	0	0	0	0	0	1	0	0 %8_2
	];


% XfvGen = zeros(FI,VI);
% coreCount = TreeMap();
% for c = 1 : 10
% 	coreCount.put(c,ArrayList());
% end
% for c = 1 : VI
% 	coreCount.get(vmCoreRequirements(vmStatus(1,c))).add(c);
% end
% vnfStatus = zeros(1,FI);
% vnfIndex = 1;
% for f = 1 : F
% 	instanceCount = vnfTypes(1,f); %required number of instances
% 	for i = 1 : instanceCount
% 		currentCore = 1;
% 		while (currentCore <= 10)
% 			availableVMs = coreCount.get(currentCore);
% 			if availableVMs.size() == 0
% 				if currentCore == 10
% 					currentCore = 11;
% 				else
% 					currentCore = coreCount.higherEntry(currentCore).getKey();
% 				end
% 			else
% 				vMachine = availableVMs.get(0);
% 				availableVMs.remove(0);
% 				XfvGen(vnfIndex,vMachine) = 1;
% 				vnfStatus(1,vnfIndex) = f;
% 				VMCores = currentCore;
% 				VMCores = VMCores-requiredCores;
% 				if VMCores > 0
%                     coreCount.get(VMCores).add(vMachine);
%                 end
% 				vnfIndex = vnfIndex+1;
% 				break;
% 			end
% 		end
%     end
% end
% Xfv = XfvGen
% nodeClassData = Node(1,zeros(1,2)); %to store the node status
% vmCount = sum(Xvn); %count of VMs on each node
% for i = 1 : N %for each node
% 	vms = zeros(1,vmCount(1,i)); %to store the exact VM instances
% 	index = 1; %start the index
% 	for v = 1 : VI %for each VM instance
% 		if (Xvn(v,i) == 1) %if the instance is placed on ith node
% 			vms(1,index) = v; %store in the array
% 			index = index+1; %increment the index
% 		end
%     end
% 	nodeClassData(1,i) = Node(vmCount(1,i),vms); %create the node object
% end

% vmClassData = VM(1,zeros(1,2)); %to store the VM status
% vnfCount = sum(Xfv); %count the vnfs on each VM
% for i = 1 : VI %for each VM instance
%     vnfs = zeros(1,vnfCount(1,i)); %to store the exact VNF instances
%     index = 1; %start the index
%     for f = 1 : FI %for each VNF instance
%         if (Xfv(f,i) == 1) %if the instance is placed on ith VM
%             vnfs(1,index) = f; %store in the array
%             index = index+1; %increment the index
%         end
%     end
%     vmClassData(1,i) = VM(vnfCount(1,i),vnfs); %create the VM object
% end

% sfcClassData = SFC(1,S,zeros(1,2),zeros(1,2));
% sfcMatrix = zeros(FI,FI);
% sfcMatrix2 = zeros(F,F);
% sfcStatus = input('Choose one option for SFC:\n\t1. Random SFC Generation\n\t2. Custom Input\nEnter your choice:\n');
% if sfcStatus == 1
% elseif sfcStatus == 2
% 	for i = 1 : S
% 		chain = zeros(1,3);
% 		if mod(i,10) == 1 && mod(i,100) ~= 11
% 			chain = input(sprintf('Enter %dst chain:\n',i));
% 		elseif mod(i,10) == 2 && mod(i,100) ~= 12
% 			chain = input(sprintf('Enter %dnd chain:\n',i));
% 		elseif mod(i,10) == 3 && mod(i,100) ~= 13
% 			chain = input(sprintf('Enter %drd chain:\n',i));
% 		else
% 			chain = input(sprintf('Enter %dth chain:\n',i));
% 		end
% 		chainLength = size(chain)-1;
%         sfcClassData(1,i) = SFC(chainLength(1,2)+1,chain,zeros(1,2),zeros(1,2));
% 		% sfcMatrix(:,:,i) = zeros(FI,FI);
% 		sfcMatrix2(:,:,i) = zeros(F,F);
% 		for node = 1 : chainLength(1,2)
% 			sfcMatrix2(chain(1,node),chain(1,node+1),i) = 1;
% 		end
% 	end
% end

% commands = "";
% % vnfStatus = [1 1 1 2 2 3 3 3 4 4 4 4 5 5 5 6 6 6 7 7 8 8];
% vmColor = ["lightblue","lightgreen","pink","orchid","coral"];

% %% Nodes to be used
% nodeNames = strings(1,N);
% for node = 1 : N %for each node
% 	% node
%     nodeName = "";
%     nodeName = nodeName+sprintf("%d",node)+"[style=filled"+newline;
%     nodeName = nodeName+"label=<"+newline;
%     nodeName = nodeName+"<TABLE BORDER=""0"" BGCOLOR=""grey"">"+newline;
%     nodeName = nodeName+"<TR>"+newline;

%     currNodeVmCount = nodeClassData(1,node).vmCount;
%     currNodeVms = nodeClassData(1,node).vms;

%     for v = 1 : currNodeVmCount %for each VM on the current node
%     	currVmVnfCount = vmClassData(1,currNodeVms(1,v)).vnfCount;
%     	currVmVnfs = vmClassData(1,currNodeVms(1,v)).vnfs;

%     	nodeName = nodeName+"<TD>"+newline;
%     	nodeName = nodeName+"<TABLE BORDER=""0"" BGCOLOR="""+vmColor(1,v)+""">"+newline;

%     	for f = 1 : currVmVnfCount %for each VNF on the current VM
%    			nodeName = nodeName+"<TR><TD PORT=""f"+sprintf("%d",vnfStatus(1,currVmVnfs(1,f)))+""" BGCOLOR="""+vmColor(1,v)+""">f<SUB>"+sprintf("%d",vnfStatus(1,currVmVnfs(1,f)))+"</SUB></TD></TR>"+newline;
%     	end
    	
%     	nodeName = nodeName+"</TABLE>"+newline;
%     	nodeName = nodeName+"</TD>"+newline;
%     end

%     nodeName = nodeName+"</TR>"+newline;
%     nodeName = nodeName+"</TABLE>>]"+newline;

%     nodeNames(1,node) = nodeName;
% end

% %% Network Print
% gvText = "digraph G";
% gvText = gvText+newline+"{";
% gvText = gvText+newline+"ranksep = ""equally""";
% gvText = gvText+newline+"rankdir = LR";
% gvText = gvText+newline+"node [shape=none]";

% rankData = "";
% nodeData = "";
% linkData = "";

% visited = zeros(1,N);
% q = LinkedList();
% q.add(1);
% visited(1,1) = 1;
% % rankData = rankData+"{rank = same; 1; };";

% while q.size() ~= 0
%     qLen = q.size();
%     rankData = rankData+newline+"{rank = same; ";
%     for i = 1 : qLen
%         node = q.remove();
%         nodeData = nodeData+newline+nodeNames(1,node);
%         rankData = sprintf("%s%d; ",rankData,node);
%         for adj = 1 : N
%             if sampleNetwork1Original(node,adj) ~= 0 && visited(1,adj) == 0
%                 q.add(adj);
%                 visited(1,adj) = 1;
%                 % linkData = linkData+newline+sprintf("%d",node)+" -- "+sprintf("%d",adj);
%             end
%         end
%     end
%     rankData = rankData+"};";
% end

% for i = 1 : N
% 	for j = i+1 : N
% 		if (sampleNetwork1Original(i,j) ~= 0)
% 			linkData = linkData+newline+sprintf("%d",i)+" -> "+sprintf("%d",j)+"[label="""+sprintf("%d",sampleNetwork1Original(i,j))+""" dir = none]";
% 		end
% 	end
% end

% gvText = gvText+rankData;
% gvText = gvText+nodeData;
% gvText = gvText+linkData;
% gvText = gvText+newline+"}";

% fileID = fopen('output/sample1/gv/graphPrint.gv','w+');
% commands = commands+"dot -Tpng gv/graphPrint.gv -o img/graph.png";
% fprintf(fileID,"%s",gvText);



% 		1 	2 	3 	4	5 	6	7	8	9	10	11	12	13
Xfv2 = [ 
		0	0	0	1	0	0	1	0	1	0	0	0	0; %1
		1	1	0	0	0	0	0	0	0	0	0	0	0; %2
		0	0	0	0	1	0	0	1	0	1	0	0	0; %3
		0	0	1	1	0	1	0	0	1	0	0	0	0; %4
		1	0	0	0	0	0	0	0	0	1	0	1	0; %5
		1	0	0	0	1	0	0	0	0	0	0	0	1; %6
		1	0	1	0	0	0	0	0	0	0	0	0	0; %7
		0	1	0	0	0	0	0	0	0	0	1	0	0; %8
	];

% SFC to VNF map --- to be generated
% 		1_1	1_2	1_3	2_1	2_2	3_1	3_2	3_3	4_1	4_2	4_3	4_4	5_1	5_2	5_3	6_1	6_2	6_3	7_1	7_2	8_1	8_2
Xsf = [ 
		0	0	1	0	0	1	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0; %1
		0	0	0	1	0	0	1	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0; %2
		0	0	1	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	1	0	1	0; %3
		0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0; %4
		0	0	1	0	0	0	0	0	0	0	1	0	0	0	1	0	0	0	0	0	0	0; %5
	];

% 		1	2	3	4	5	6	7	8
Xsf2 = [ 
		1	0	1	1	0	0	0	0; %1
		0	1	1	0	1	0	0	0; %2
		1	0	0	1	0	0	1	1; %3
		0	1	0	0	0	1	0	0; %4
		1	0	0	1	1	0	0	0; %5
	];

% SFC graphs --- to be generated
% SFC-1 : f1 -> f4 -> f3
% SFC-2 : f3 -> f2 -> f5
% SFC-3 : f4 -> f8 -> f7 -> f1
% SFC-4 : f2 -> f6
% SFC-5 : f5 -> f1 -> f4

nodeClassData = Node(1,zeros(1,2)); %to store the node status
vmCount = sum(Xvn); %count of VMs on each node
for i = 1 : N %for each node
	vms = zeros(1,vmCount(1,i)); %to store the exact VM instances
	index = 1; %start the index
	for v = 1 : VI %for each VM instance
		if (Xvn(v,i) == 1) %if the instance is placed on ith node
			vms(1,index) = v; %store in the array
			index = index+1; %increment the index
		end
    end
	nodeClassData(1,i) = Node(vmCount(1,i),vms); %create the node object
end

vmClassData = VM(1,zeros(1,2)); %to store the VM status
vnfCount = sum(Xfv); %count the vnfs on each VM
for i = 1 : VI %for each VM instance
    vnfs = zeros(1,vnfCount(1,i)); %to store the exact VNF instances
    index = 1; %start the index
    for f = 1 : FI %for each VNF instance
        if (Xfv(f,i) == 1) %if the instance is placed on ith VM
            vnfs(1,index) = f; %store in the array
            index = index+1; %increment the index
        end
    end
    vmClassData(1,i) = VM(vnfCount(1,i),vnfs); %create the VM object
end

sfcClassData = SFC(1,S,zeros(1,2),zeros(1,2));
sfcMatrix = zeros(FI,FI);
sfcMatrix2 = zeros(F,F);
sfcStatus = input('Choose one option for SFC:\n\t1. Random SFC Generation\n\t2. Custom Input\nEnter your choice:\n');
if sfcStatus == 1
elseif sfcStatus == 2
	for i = 1 : S
		chain = zeros(1,3);
		if mod(i,10) == 1 && mod(i,100) ~= 11
			chain = input(sprintf('Enter %dst chain:\n',i));
		elseif mod(i,10) == 2 && mod(i,100) ~= 12
			chain = input(sprintf('Enter %dnd chain:\n',i));
		elseif mod(i,10) == 3 && mod(i,100) ~= 13
			chain = input(sprintf('Enter %drd chain:\n',i));
		else
			chain = input(sprintf('Enter %dth chain:\n',i));
		end
		chainLength = size(chain)-1;
        sfcClassData(1,i) = SFC(chainLength(1,2)+1,chain,zeros(1,2),zeros(1,2));
		% sfcMatrix(:,:,i) = zeros(FI,FI);
		sfcMatrix2(:,:,i) = zeros(F,F);
		for node = 1 : chainLength(1,2)
			sfcMatrix2(chain(1,node),chain(1,node+1),i) = 1;
		end
	end
end

% sfcMatrix2

% 		1_1	1_2	1_3	2_1	2_2	3_1	3_2	3_3	4_1	4_2	4_3	4_4	5_1	5_2	5_3	6_1	6_2	6_3	7_1	7_2	8_1	8_2
sfcMatrix = [ 
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %1_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %1_2
		0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0; %1_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %2_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %2_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_1
		0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_4
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %7_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %7_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %8_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0 %8_2
	];

% %		1	2	3	4	5	6	7	8
% sfcMatrix2 = [ 0	0	0	1	0	0	0	0; %1
% 		0	0	0	0	0	0	0	0; %2
% 		0	0	0	0	0	0	0	0; %3
% 		0	0	1	0	0	0	0	0; %4
% 		0	0	0	0	0	0	0	0; %5
% 		0	0	0	0	0	0	0	0; %6
% 		0	0	0	0	0	0	0	0; %7
% 		0	0	0	0	0	0	0	0 %8
% 	];

% 		1_1	1_2	1_3	2_1	2_2	3_1	3_2	3_3	4_1	4_2	4_3	4_4	5_1	5_2	5_3	6_1	6_2	6_3	7_1	7_2	8_1	8_2
sfcMatrix(:,:,2) = [ 
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %1_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %1_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %1_3
		0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0; %2_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %2_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_1
		0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_4
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %7_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %7_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %8_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0 %8_2
	];

% % 				1	2	3	4	5	6	7	8
% sfcMatrix2(:,:,2) = [	0	0	0	0	0	0	0	0; %1
% 				0	0	0	0	1	0	0	0; %2
% 				0	1	0	0	0	0	0	0; %3
% 				0	0	0	0	0	0	0	0; %4
% 				0	0	0	0	0	0	0	0; %5
% 				0	0	0	0	0	0	0	0; %6
% 				0	0	0	0	0	0	0	0; %7
% 				0	0	0	0	0	0	0	0 %8
% 			];

% 		1_1	1_2	1_3	2_1	2_2	3_1	3_2	3_3	4_1	4_2	4_3	4_4	5_1	5_2	5_3	6_1	6_2	6_3	7_1	7_2	8_1	8_2
sfcMatrix(:,:,3) = [ 
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %1_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %1_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %1_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %2_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %2_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0; %4_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_4
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_3
		0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %7_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %7_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0; %8_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0 %8_2
	];

% % 				1	2	3	4	5	6	7	8
% sfcMatrix2(:,:,3) = [	0	0	0	0	0	0	0	0; %1
% 				0	0	0	0	0	0	0	0; %2
% 				0	0	0	0	0	0	0	0; %3
% 				0	0	0	0	0	0	0	1; %4
% 				0	0	0	0	0	0	0	0; %5
% 				0	0	0	0	0	0	0	0; %6
% 				1	0	0	0	0	0	0	0; %7
% 				0	0	0	0	0	0	1	0 %8
% 			];

% 		1_1	1_2	1_3	2_1	2_2	3_1	3_2	3_3	4_1	4_2	4_3	4_4	5_1	5_2	5_3	6_1	6_2	6_3	7_1	7_2	8_1	8_2
sfcMatrix(:,:,4) = [ 
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %1_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %1_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %1_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	1	0	0	0	0; %2_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %2_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_4
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %7_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %7_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %8_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0 %8_2
	];

% % 				1	2	3	4	5	6	7	8
% sfcMatrix2(:,:,4) = [	0	0	0	0	0	0	0	0; %1
% 				0	0	0	0	0	1	0	0; %2
% 				0	0	0	0	0	0	0	0; %3
% 				0	0	0	0	0	0	0	0; %4
% 				0	0	0	0	0	0	0	0; %5
% 				0	0	0	0	0	0	0	0; %6
% 				0	0	0	0	0	0	0	0; %7
% 				0	0	0	0	0	0	0	0 %8
% 			];

% 		1_1	1_2	1_3	2_1	2_2	3_1	3_2	3_3	4_1	4_2	4_3	4_4	5_1	5_2	5_3	6_1	6_2	6_3	7_1	7_2	8_1	8_2
sfcMatrix(:,:,5) = [ 
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %1_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %1_2
		0	0	0	0	0	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0; %1_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %2_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %2_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4_4
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_2
		0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %6_3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %7_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %7_2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %8_1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0 %8_2
	];

% % 				1	2	3	4	5	6	7	8
% sfcMatrix2(:,:,5) = [	0	0	0	1	0	0	0	0; %1
% 				0	0	0	0	0	0	0	0; %2
% 				0	0	0	0	0	0	0	0; %3
% 				0	0	0	0	0	0	0	0; %4
% 				1	0	0	0	0	0	0	0; %5
% 				0	0	0	0	0	0	0	0; %6
% 				0	0	0	0	0	0	0	0; %7
% 				0	0	0	0	0	0	0	0 %8
% 			];


% 		1_1	1_2	1_3	2_1	2_2	3_1	3_2	3_3	4_1	4_2	4_3	4_4	5_1	5_2	5_3	6_1	6_2	6_3	7_1	7_2	8_1	8_2
% packet arrival rates
lambda = [ 
		2	2	2	0	0	3	3	3	4	4	4	4	0	0	0	0	0	0	0	0	0	0; %1
		0	0	0	4	4	3	3	3	0	0	0	0	2	2	2	0	0	0	0	0	0	0; %2
		1	1	1	0	0	0	0	0	3	3	3	3	0	0	0	0	0	0	2	2	4	4; %3
		0	0	0	2	2	0	0	0	0	0	0	0	0	0	0	3	3	3	0	0	0	0; %4
		1	1	1	0	0	0	0	0	2	2	2	2	3	3	3	0	0	0	0	0	0	0; %5
	];
% packet drop rates
delta = [ 
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %1
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %2
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %3
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %4
		0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0; %5
	];

% 			1	2	3	4	5	6	7	8
% packet arrival rates
lambda2 = [	2	0	3	4	0	0	0	0; %1
			0	4	3	0	2	0	0	0; %2
			1	0	0	3	0	0	2	4; %3
			0	2	0	0	0	3	0	0; %4
			1	0	0	2	3	0	0	0 %5
		];
% packet drop rates
delta2 = [	0	0	0	0	0	0	0	0; %1
			0	0	0	0	0	0	0	0; %2
			0	0	0	0	0	0	0	0; %3
			0	0	0	0	0	0	0	0; %4
			0	0	0	0	0	0	0	0 %5
		];
% service rates
% 		1_1	1_2	1_3	2_1	2_2	3_1	3_2	3_3	4_1	4_2	4_3	4_4	5_1	5_2	5_3	6_1	6_2	6_3	7_1	7_2	8_1	8_2
mu = [ 	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1];
% 		1	2	3	4	5	6	7	8
mu2 = [	1	1	1	1	1	1	1	1];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Binary Variables
Xfvi = Xfv; % for iota 0, this new binary variable boils down to the existing binary variable indicating the VNF deployment
Xski = Xsf; % for iota 0, this new binary vairable boils down to the existing binary variable indicating the SFC assignment



%% Terms
% Failure Factor


% y_1
% y1 = 0;
% for n = 1 : N %1 to 6
% 	for v = 1 : VI %1 to 13
% 		% fprintf('%d node, %d VM :',n,v);
% 		y1 = y1 + Cv(1,vms(v))*Xvn(v,n);
% 	end
% end
% for v = 1 : VI %1 to 13
% 	for f = 1 : FI %1 to 22
% 		y1 = y1 + Cf(1,vnfs(f))*Xfv(f,v);
% 		% if (Xfv(f,v) ~= 0)
% 		% 	fprintf('%d VM, %d vnf',v,f);
% 		% 	y1
% 		% end
% 	end
% end

% % y_2
% y2 = 0;
% dq = zeros(1,FI); % Queueing Delay
% for f = 1 : FI %1 to 22
% 	lambdaSF = 0;
% 	deltaSF = 0;
% 	for s = 1 : S %1 to 5
% 		lambdaSF = lambdaSF+lambda(s,f);
% 		deltaSF = deltaSF+delta(s,f);
% 	end
% 	dq(1,f) = (lambdaSF-deltaSF)/mu(1,f);
% end
% dpc = zeros(1,FI); % Processing Delay
% for f = 1 : FI %1 to 22
%     dpc(1,f) = 1/mu(1,f);
% end
% for s = 1 : S %1 to 5
%     for v = 1 : VI %1 to 13
%         for f = 1 : FI %1 to 22
%             y2 = y2+(dq(1,f)+dpc(1,f))*Xfvi(f,v)*Xski(s,f);
%             % if (Xfvi(f,v)*Xski(s,f) ~= 0)
%             %     fprintf('%d %d %d = ',s,f,v);
%             %     y2
%             % end
%         end
%     end
% end

% % y_3
% y3 = 0;
% for s = 1 : S %1 to 5
%     currSfcLength = sfcLengths(1,s); %get the length of sth sfc
%     currSfcMatrix = sfcMatrix(:,:,s); %get the sth sfc matrix
%     for currSfcNode = 1 : currSfcLength-1 %for all edges
%         currSrc = 0;
%         currDest = 0;
%         vnfRow = -1;
%         vnfCol = -1;
%         % fprintf('\n\n sfc %d, length %d', s, currSfcLength);
%         for r = 1 : FI %1 to 22
%             for c = 1 : FI %1 to 22
%                 if currSfcMatrix(r,c) == 1 %if a virtual link is found
%                     vnfRow = r; %store the row
%                     vnfCol = c; %store the column
%                     currSfcMatrix(r,c) = 0; %mark the link as visited
%                     break;
%                 end
%             end
%             if vnfRow ~= -1
%                 break;
%             end
%         end
%         vmSrc = -1;
%         vmDest = -1;
%         for vm = 1 : VI %1 to 13
%             if Xfv(vnfRow,vm) == 1 %if the corresponding VM is spotted
%                 vmSrc = vm; %store the corresponding source vm
%                 break;
%             end
%         end
%         for vm = 1 : VI %1 to 13
%             if Xfv(vnfCol,vm) == 1 %if the corresponding VM is spotted
%                 vmDest = vm; %store the corresponding destination vm
%                 break;
%             end
%         end
%         for node = 1 : N %1 to 6
%             if Xvn(vmSrc,node) == 1 %if the corresponding physical node is spotted
%                 currSrc = node; %store the corresponding source node
%                 break;
%             end
%         end
%         for node = 1 : N %1 to 6
%             if Xvn(vmDest,node) == 1 %if the corresponding physical node is spotted
%                 currDest = node; %store the corresponding destination node
%                 break;
%             end
%         end
%         % s
%         % currSrc
%         % currDest
%         y3 = y3+sampleNetwork1(currSrc,currDest);
%         % y3
%         % fprintf('===============================================\n');
%     end
% end

[y1, y2, y3] = objective(N, VI, FI, S, L, medium, sfcLengths, sampleNetwork1Original, sampleNetwork1, nextHop, bandwidths, sfcMatrix, Cv, Cf, Xvn, Xfv, lambda, delta, mu, Xfvi, Xski, vmStatus, vnfStatus);

% dot commands
commands = "";
% vnfStatus = [1 1 1 2 2 3 3 3 4 4 4 4 5 5 5 6 6 6 7 7 8 8];
vmColor = ["lightblue","lightgreen","pink","orchid","coral"];

%% Nodes to be used
nodeNames = strings(1,N);
for node = 1 : N %for each node
	% node
    nodeName = "";
    nodeName = nodeName+sprintf("%d",node)+"[style=filled"+newline;
    nodeName = nodeName+"label=<"+newline;
    nodeName = nodeName+"<TABLE BORDER=""0"" BGCOLOR=""grey"">"+newline;
    nodeName = nodeName+"<TR>"+newline;

    currNodeVmCount = nodeClassData(1,node).vmCount;
    currNodeVms = nodeClassData(1,node).vms;

    for v = 1 : currNodeVmCount %for each VM on the current node
    	currVmVnfCount = vmClassData(1,currNodeVms(1,v)).vnfCount;
    	currVmVnfs = vmClassData(1,currNodeVms(1,v)).vnfs;

    	nodeName = nodeName+"<TD>"+newline;
    	nodeName = nodeName+"<TABLE BORDER=""0"" BGCOLOR="""+vmColor(1,v)+""">"+newline;

    	for f = 1 : currVmVnfCount %for each VNF on the current VM
   			nodeName = nodeName+"<TR><TD PORT=""f"+sprintf("%d",vnfStatus(1,currVmVnfs(1,f)))+""" BGCOLOR="""+vmColor(1,v)+""">f<SUB>"+sprintf("%d",vnfStatus(1,currVmVnfs(1,f)))+"</SUB></TD></TR>"+newline;
    	end
    	
    	nodeName = nodeName+"</TABLE>"+newline;
    	nodeName = nodeName+"</TD>"+newline;
    end

    nodeName = nodeName+"</TR>"+newline;
    nodeName = nodeName+"</TABLE>>]"+newline;

    nodeNames(1,node) = nodeName;
end

%% Network Print
gvText = "digraph G";
gvText = gvText+newline+"{";
gvText = gvText+newline+"ranksep = ""equally""";
gvText = gvText+newline+"rankdir = LR";
gvText = gvText+newline+"node [shape=none]";

rankData = "";
nodeData = "";
linkData = "";

import java.util.LinkedList;

visited = zeros(1,N);
q = LinkedList();
q.add(1);
visited(1,1) = 1;
% rankData = rankData+"{rank = same; 1; };";

while q.size() ~= 0
    qLen = q.size();
    rankData = rankData+newline+"{rank = same; ";
    for i = 1 : qLen
        node = q.remove();
        nodeData = nodeData+newline+nodeNames(1,node);
        rankData = sprintf("%s%d; ",rankData,node);
        for adj = 1 : N
            if sampleNetwork1Original(node,adj) ~= 0 && visited(1,adj) == 0
                q.add(adj);
                visited(1,adj) = 1;
                % linkData = linkData+newline+sprintf("%d",node)+" -- "+sprintf("%d",adj);
            end
        end
    end
    rankData = rankData+"};";
end

for i = 1 : N
	for j = i+1 : N
		if (sampleNetwork1Original(i,j) ~= 0)
			linkData = linkData+newline+sprintf("%d",i)+" -> "+sprintf("%d",j)+"[label="""+sprintf("%d",sampleNetwork1Original(i,j))+""" dir = none]";
		end
	end
end

gvText = gvText+rankData;
gvText = gvText+nodeData;
gvText = gvText+linkData;
gvText = gvText+newline+"}";

fileID = fopen('output/sample1/gv/graphPrint.gv','w+');
commands = commands+"dot -Tpng gv/graphPrint.gv -o img/graph.png";
fprintf(fileID,"%s",gvText);

%% SFC print
for c = 1 : S
	gvText = "digraph G";
	gvText = gvText+newline+"{";
	gvText = gvText+newline+"ranksep = ""equally""";
	gvText = gvText+newline+"rankdir = LR";
	gvText = gvText+newline+"node [shape=circle]";

	rankData = "";
	nodeData = "";
	linkData = "";

	chainLength = sfcClassData(1,c).chainLength;
	chain = sfcClassData(1,c).chain;

	for node = 1 : chainLength-1
		rankData = rankData+newline+"{rank = same; ";
		rankData = sprintf("%s%s%d; ",rankData,'f',chain(1,node));
		rankData = rankData+"};";
		% nodeData = nodeData+newline+sprintf("%s%d",'f',chain(1,node))+"[style=filled label=<f<SUB>"+chain(1,node)+"</SUB>> color="""+sprintf("%s",colors(1,chain(1,node)))+"""]";
		nodeData = nodeData+newline+sprintf("%s%d",'f',chain(1,node))+"[style=filled label=<f<SUB>"+chain(1,node)+"</SUB>> color=""lightgrey""]";
		linkData = linkData+newline+sprintf("%s%d",'f',chain(1,node))+" -> "+sprintf("%s%d",'f',chain(1,node+1));
	end

	rankData = rankData+newline+"{rank = same; ";
	rankData = sprintf("%s%s%d; ",rankData,'f',chain(1,chainLength));
	rankData = rankData+"};";
	% nodeData = nodeData+newline+sprintf("%s%d",'f',chain(1,chainLength))+"[style=filled label=<f<SUB>"+chain(1,chainLength)+"</SUB>> color="""+sprintf("%s",colors(1,chain(1,chainLength)))+"""]";
	nodeData = nodeData+newline+sprintf("%s%d",'f',chain(1,chainLength))+"[style=filled label=<f<SUB>"+chain(1,chainLength)+"</SUB>> color=""lightgrey""]";
	gvText = gvText+rankData;
	gvText = gvText+nodeData;
	gvText = gvText+linkData;
	gvText = gvText+newline+"}";

	fileID = fopen(sprintf('%s%d%s','output/sample1/gv/sfc',c,'.gv'),'w+');
	commands = commands+newline+"dot -Tpng "+sprintf('%s%d%s','gv/sfc',c,'.gv')+" -o "+sprintf('%s%d%s','img/sfc',c,'.png');
	fprintf(fileID,"%s",gvText);
end

%% SFC assignment print
for ch = 1 : S %1 to 5
    currSfcLength = sfcLengths(1,ch); %get the length of sth sfc
    currSfcMatrix = sfcMatrix(:,:,ch); %get the sth sfc matrix
    sfcClassData(1,ch).usedLinks = zeros(currSfcLength-1,2); %keeps track of the used links for the sfc
    sfcClassData(1,ch).usedInstances = zeros(N,F); %keeps track of the used physical nodes for the sfc
    for currSfcNode = 1 : currSfcLength-1 %for all edges
        currSrc = 0;
        currDest = 0;
        vnfRow = -1;
        vnfCol = -1;
        % fprintf('\n\n sfc %d, length %d', s, currSfcLength);
        for r = 1 : FI %1 to 22
            for c = 1 : FI %1 to 22
                if currSfcMatrix(r,c) == 1 %if a virtual link is found
                    vnfRow = r; %store the row
                    vnfCol = c; %store the column
                    currSfcMatrix(r,c) = 0; %mark the link as visited
                    break;
                end
            end
            if vnfRow ~= -1
                break;
            end
        end
        vmSrc = -1;
        vmDest = -1;
        for vm = 1 : VI %1 to 13
            if Xfv(vnfRow,vm) == 1 %if the corresponding VM is spotted
                vmSrc = vm; %store the corresponding source vm
                break;
            end
        end
        for vm = 1 : VI %1 to 13
            if Xfv(vnfCol,vm) == 1 %if the corresponding VM is spotted
                vmDest = vm; %store the corresponding destination vm
                break;
            end
        end
        for node = 1 : N %1 to 6
            if Xvn(vmSrc,node) == 1 %if the corresponding physical node is spotted
                currSrc = node; %store the corresponding source node
                break;
            end
        end
        for node = 1 : N %1 to 6
            if Xvn(vmDest,node) == 1 %if the corresponding physical node is spotted
                currDest = node; %store the corresponding destination node
                break;
            end
        end
        % s
        % currSrc
        % currDest
        sfcClassData(1,ch).usedLinks(currSfcNode,1) = currSrc;
        sfcClassData(1,ch).usedLinks(currSfcNode,2) = currDest;
        sfcClassData(1,ch).usedInstances(currSrc,vnfStatus(1,vnfRow)) = 1;
        sfcClassData(1,ch).usedInstances(currDest,vnfStatus(1,vnfCol)) = 1;
    	% sfcClassData(1,c).usedLinks = usedLinks; %keeps track of the used links for the sfc
        % y3
        % fprintf('===============================================\n');
    end
    % sfcClassData(1,ch).chainLength
    % sfcClassData(1,ch).chain
    % sfcClassData(1,ch).usedLinks
end

for c = 1 : S
	chainLength = sfcClassData(1,c).chainLength;
	chain = sfcClassData(1,c).chain;
	usedLinks = sfcClassData(1,c).usedLinks;
	usedInstances = sfcClassData(1,c).usedInstances;
	nodeNames = strings(1,N);
	for node = 1 : N %for each node
		% node
	    nodeName = "";
	    nodeName = nodeName+sprintf("%d",node)+"[style=filled"+newline;
	    nodeName = nodeName+"label=<"+newline;
	    nodeName = nodeName+"<TABLE BORDER=""0"" BGCOLOR=""grey"">"+newline;
	    nodeName = nodeName+"<TR>"+newline;

	    currNodeVmCount = nodeClassData(1,node).vmCount;
	    currNodeVms = nodeClassData(1,node).vms;

	    for v = 1 : currNodeVmCount %for each VM on the current node
	    	currVmVnfCount = vmClassData(1,currNodeVms(1,v)).vnfCount;
	    	currVmVnfs = vmClassData(1,currNodeVms(1,v)).vnfs;

	    	nodeName = nodeName+"<TD>"+newline;
	    	nodeName = nodeName+"<TABLE BORDER=""0"" BGCOLOR=""darkgrey"">"+newline;

	    	for f = 1 : currVmVnfCount %for each VNF on the current VM
	    		if usedInstances(node,vnfStatus(1,currVmVnfs(1,f))) == 1
	   				nodeName = nodeName+"<TR><TD PORT=""f"+sprintf("%d",vnfStatus(1,currVmVnfs(1,f)))+""" BGCOLOR=""bisque"">f<SUB>"+sprintf("%d",vnfStatus(1,currVmVnfs(1,f)))+"</SUB></TD></TR>"+newline;
	   			else	
	   				nodeName = nodeName+"<TR><TD PORT=""f"+sprintf("%d",vnfStatus(1,currVmVnfs(1,f)))+""" BGCOLOR=""darkgrey"">f<SUB>"+sprintf("%d",vnfStatus(1,currVmVnfs(1,f)))+"</SUB></TD></TR>"+newline;
	    		end
	    	end
	    	
	    	nodeName = nodeName+"</TABLE>"+newline;
	    	nodeName = nodeName+"</TD>"+newline;
	    end

	    nodeName = nodeName+"</TR>"+newline;
	    nodeName = nodeName+"</TABLE>>]"+newline;

	    nodeNames(1,node) = nodeName;
	end

	gvText = "digraph G";
	gvText = gvText+newline+"{";
	gvText = gvText+newline+"ranksep = ""equally""";
	gvText = gvText+newline+"rankdir = LR";
	gvText = gvText+newline+"node [shape=none]";

	rankData = "";
	nodeData = "";
	linkData = "";

	import java.util.LinkedList;

	visited = zeros(1,N);
	q = LinkedList();
	q.add(1);
	visited(1,1) = 1;
	% rankData = rankData+"{rank = same; 1; };";

	while q.size() ~= 0
	    qLen = q.size();
	    rankData = rankData+newline+"{rank = same; ";
	    for i = 1 : qLen
	        node = q.remove();
	        % nodeData = nodeData+newline+sprintf("%d",node)+"[color="""+sprintf("%s",'grey')+"""]";
	        rankData = sprintf("%s%d; ",rankData,node);
	        for adj = 1 : N
	            if sampleNetwork1Original(node,adj) ~= 0 && visited(1,adj) == 0 %if the link is connected in the original graph and not visited
	                q.add(adj); %add to queue
	                visited(1,adj) = 1; %mark as visited
	                % linkData = linkData+newline+sprintf("%d",node)+" -- "+sprintf("%d",adj);
	            end
	        end
	    end
	    rankData = rankData+"};";
	end

	% currSfcAssgn = sampleNetwork1Original;
	% for l = 1 : chainLength-1
	% 	currSfcAssgn(usedLinks(l,1),usedLinks(l,2)) = currSfcAssgn(usedLinks(l,1),usedLinks(l,2))*(-1);
	% 	% sampleNetwork1Original(usedLinks(l,2),usedLinks(l,1)) = sampleNetwork1Original(usedLinks(l,2),usedLinks(l,1))*(-1);
	% end
	% sfcClassData(1,c) = SFC(chainLength,chain,usedLinks);

	% for i = 1 : N
	% 	for j = i+1 : N
	% 		if (currSfcAssgn(i,j) ~= 0)
	% 			if (currSfcAssgn(i,j) < 0)
	% 				linkData = linkData+newline+sprintf("%d",i)+" -> "+sprintf("%d",j)+"[label="""+sprintf("%d",currSfcAssgn(j,i))+""" color="""+sprintf("%s",'black')+"""]";
	% 			elseif (currSfcAssgn(j,i) < 0)
	% 				linkData = linkData+newline+sprintf("%d",j)+" -> "+sprintf("%d",i)+"[label="""+sprintf("%d",currSfcAssgn(i,j))+""" color="""+sprintf("%s",'black')+"""]";
 %                else
	% 				linkData = linkData+newline+sprintf("%d",i)+" -> "+sprintf("%d",j)+"[label="""+sprintf("%d",currSfcAssgn(i,j))+""" color="""+sprintf("%s",'grey')+""" dir = none]";
	% 			end
	% 		end
	% 	end
	% end

	visitedEdge = zeros(N,N);
	visitedNode = zeros(1,N);
	for link = 1 : chainLength-1 %for each link in the usedlinks
		currSrc = usedLinks(link,1); %get the source
		currDest = usedLinks(link,2); %get the destination
		startNode = currSrc; %mark source as starting node
		nodeData = nodeData+newline+nodeNames(1,currSrc); %add into node data with black color
		visitedNode(1,currSrc) = 1; %mark source as visited
		while (startNode ~= currDest) %till starting node becomes equal to the destination
			uNode = startNode; %get the current node
			vNode = nextHop(startNode,currDest); %get the next hop node
			% if (startNode == currSrc)
			% 	linkData = linkData+newline+sprintf("%d",uNode)+":f"+chain(1,link)+" -> "+sprintf("%d",vNode)+"[label="""+sprintf("%d",sampleNetwork1Original(uNode,vNode))+""" color="""+sprintf("%s",'black')+"""]"; %include the link data with black color
			% elseif (nextHop(startNode,currDest) == currDest)
			% 	linkData = linkData+newline+sprintf("%d",uNode)+" -> "+sprintf("%d",vNode)+":f"+chain(1,link+1)+" [label="""+sprintf("%d",sampleNetwork1Original(uNode,vNode))+""" color="""+sprintf("%s",'black')+"""]"; %include the link data with black color
			% else
				linkData = linkData+newline+sprintf("%d",uNode)+" -> "+sprintf("%d",vNode)+"[label="""+sprintf("%d",sampleNetwork1Original(uNode,vNode))+""" color="""+sprintf("%s",'black')+"""]"; %include the link data with black color
			% end
			visitedEdge(startNode,nextHop(startNode,currDest)) = 1; %mark edge as visited
			visitedEdge(nextHop(startNode,currDest),startNode) = 1; %mark edge as visited
			startNode = nextHop(startNode,currDest); %update the current node
        end
        if (visitedNode(1,currDest) ~= 1) %if the destination is not already visited
            visitedNode(1,currDest) = 1; %mark destination node as visited
	        nodeData = nodeData+newline+nodeNames(1,currDest); %include destination node in black color
        end
    end
	
	for i = 1 : N
		for j = i+1 : N
			if (sampleNetwork1Original(i,j) ~= 0) %if the edge exists in the original network
				if (visitedNode(1,i) ~= 1) %if ith node is not already visited
					nodeData = nodeData+newline+nodeNames(1,i); %include in grey color
					visitedNode(1,i) = 1; %mark as visited
				end
				if (visitedNode(1,j) ~= 1) %if ith node is not already visited
					nodeData = nodeData+newline+nodeNames(1,j); %include in grey color
					visitedNode(1,j) = 1; %mark as visited
				end
				if (visitedEdge(i,j) ~= 1) %if the edge between them is not visited
					linkData = linkData+newline+sprintf("%d",i)+" -> "+sprintf("%d",j)+"[label="""+sprintf("%d",sampleNetwork1Original(i,j))+""" color="""+sprintf("%s",'grey')+""" dir = none]"; %include in grey color
					visitedEdge(i,j) = 1; %mark as visited
					visitedEdge(j,i) = 1; %mark as visited
				end
				% if (currSfcAssgn(i,j) < 0)
				% 	linkData = linkData+newline+sprintf("%d",i)+" -> "+sprintf("%d",j)+"[label="""+sprintf("%d",currSfcAssgn(j,i))+""" color="""+sprintf("%s",'black')+"""]";
				% elseif (currSfcAssgn(j,i) < 0)
				% 	linkData = linkData+newline+sprintf("%d",j)+" -> "+sprintf("%d",i)+"[label="""+sprintf("%d",currSfcAssgn(i,j))+""" color="""+sprintf("%s",'black')+"""]";
    %             else
				% 	linkData = linkData+newline+sprintf("%d",i)+" -> "+sprintf("%d",j)+"[label="""+sprintf("%d",currSfcAssgn(i,j))+""" color="""+sprintf("%s",'grey')+""" dir = none]";
				% end
			end
		end
	end

	gvText = gvText+rankData;
	gvText = gvText+nodeData;
	gvText = gvText+linkData;
	gvText = gvText+newline+"}";

	fileID = fopen(sprintf('%s%d%s','output/sample1/gv/sfcAssgn',c,'.gv'),'w+');
	commands = commands+newline+"dot -Tpng "+sprintf('%s%d%s','gv/sfcAssgn',c,'.gv')+" -o "+sprintf('%s%d%s','img/sfcAssgn',c,'.png');
	fprintf(fileID,"%s",gvText);
end

fileID = fopen('output/sample1/commands.bat','w+');
fprintf(fileID,"%s",commands);
fclose(fileID);

y1
y2
y3