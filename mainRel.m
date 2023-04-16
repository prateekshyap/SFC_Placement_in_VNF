clear all
close all
clc

global VMCombination;
global VMCost;
global VNFDeployment;
global SFCAssignment;
global SFCCost;
global SFCData;
global globFvMap;
global minSfcCost;
global minXsfComb;
global minSfcData;
global deployCount;
global assignCount;
global mutationProbability;
global mutationCount;
global randomMutationIterations;
global discovery;
global low;
global visited;
global isBridge;
global time;
global costStorage;
global timeStorage;

import java.util.TreeMap;
import java.util.HashSet;
import java.util.ArrayList;
import java.util.LinkedList;

%% Data Generation File
logFileID = fopen('log.txt','wt');

%% Constants and Variables
costOldGA = zeros(3,100); %%%%%%% UNCOMMENT AT NIGHT
costNewGA = zeros(3,100); %%%%%%% UNCOMMENT AT NIGHT
% for loop = 1 : 100
% sVal = [10 20];
parfor loop = 1 : 100 %%%%%%% UNCOMMENT AT NIGHT
% loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


inputFilePath = 'input/india_35_80/';
outputFilePath = 'output/india_35_80/';
fileID = fopen(sprintf("%s%s",inputFilePath,'constants.txt'),'r');
formatSpecifier = '%f';
dimension = [1,10];

constants = fscanf(fileID,formatSpecifier,dimension);
fclose(fileID);

N = constants(1); %Number of nodes in the physical network
V = constants(2); %Types of VMs being considered
VI = 0; %Total number of VM instances
F = constants(3); %Types of VNFs being considered
FI = 0; %Total number of VNF instances
S = 0; %Total number of SFCs
vnfCoreRequirement = constants(4); %Required number of cores for each function
medium = constants(5); %Inverted Velocity depending on the transmission medium

% Weighing factor
alpha = constants(6);

% Failure Probabilities
rhoNode = constants(7); %Failure probability of nodes
rhoVm = constants(8); %Failure probability of VMs
rhoVnf = constants(9); %Failure probability of VNFs

% Other constants
L = constants(10); %Packet size

%% Reading Network Data
fileID = fopen(sprintf("%s%s",inputFilePath,'network.txt'),'r');
formatSpecifier = '%f';
dimension = [N,N];

inputNetwork = fscanf(fileID,formatSpecifier,dimension); %Physical network
fclose(fileID);

%% Generating Network Data
% [inputNetwork] = generateNetwork(N,126);


% for i = 1 : N
%     for j = 1 : N
%         if inputNetwork(i,j) ~= inputNetwork(j,i)
%             fprintf('Incorrect Network at %d,%d',i,j);
%         end
%     end
% end

[network,nextHop] = allPairShortestPath(N,inputNetwork); %Floyd-Warshall
[bridgeStatus] = findBridges(N,inputNetwork); % Find bridge status for all edges in the network

%% Reading Network Data
% fileID = fopen(sprintf("%s%s",inputFilePath,'bandwidth.txt'),'r');
% formatSpecifier = '%f';
% dimension = [N,N];
% bandwidths = fscanf(fileID,formatSpecifier,dimension); %Bandwidths of physical links
% fclose(fileID);

%% Generating Network Data
fileID = fopen(sprintf("%s%s",inputFilePath,'bandwidthRange.txt'),'r');
bandwidthRange = fscanf(fileID,'%f',[1,2]);
[bandwidths] = generateBandwidth(inputNetwork,N,bandwidthRange);

%% Reading Node Types
fileID = fopen(sprintf("%s%s",inputFilePath,'nodeTypes.txt'),'r');
formatSpecifier = '%d';
dimension = [1,N];
nodeStatus = fscanf(fileID,formatSpecifier,dimension); %Type of nodes indicating the number of cores
fclose(fileID);

%% Generating Node Types
% networkCopy = inputNetwork;
% for i = 1 : N
%     for j = 1 : N
%         if (networkCopy(i,j) ~= 0)
%             networkCopy(i,j) = 1;
%         end
%     end
% end
% nodeStatus(:) = sum(networkCopy);
% for n = 1 : N % For each node
% 	if nodeStatus(n) >= 8 % If the degree exceeds 8
% 		nodeStatus(n) = 6; % It will have 6 free cores
% 	else
% 		nodeStatus(n) = 2; % It will have 2 free cores
% 	end
% end

fileID = fopen(sprintf("%s%s",inputFilePath,'vmTypes.txt'),'r');
formatSpecifier = '%d';
dimension = [V,2];
temp = fscanf(fileID,formatSpecifier,dimension); %Type of VMs and their requirements
fclose(fileID);
vmTypes = temp(1:V,1)';
vmCoreRequirements = temp(1:V,2)';
VI = sum(vmTypes);

fileID = fopen(sprintf("%s%s",inputFilePath,'vnfTypes.txt'),'r');
formatSpecifier = '%d';
dimension = [1,F];
vnfTypes = fscanf(fileID,formatSpecifier,dimension); %Type of VNFs and their requirements
fclose(fileID);
FI = sum(vnfTypes);

fileID = fopen(sprintf("%s%s",inputFilePath,'costVN.txt'),'r');
formatSpecifier = '%f';
dimension = [1,V];
Cvn = fscanf(fileID,formatSpecifier,dimension); %Cost of hosting VMs on Nodes
fclose(fileID);

% Cost of deploying VNFs on VMs
fileID = fopen(sprintf("%s%s",inputFilePath,'costFV.txt'),'r');
formatSpecifier = '%f';
dimension = [V,F];
Cfv = fscanf(fileID,formatSpecifier,dimension); %Cost of deploying VNFs on VMs
fclose(fileID);

%% Array to store all SFC objects
sfcClassData = SFC(1,S,zeros(1,2),zeros(1,2));
lengths = 0;
sfcStatus = 1; % Set this for random generation or manual input
if sfcStatus == 1 %Random SFC generation
    S = 10;
	lengthStatus = 1;
    if lengthStatus == 1
        lengths = randi(ceil(F*0.6),[1,S])+2;
    elseif lengthStatus == 2
        lengths = input('Enter the lengths as an array:\n');
    end
    for i = 1 : S
        chain = randperm(F,lengths(i)) % Generate a random permutation as an SFC
        sfcClassData(1,i) = SFC(lengths(i),chain,zeros(1,2),zeros(1,2)); % Store the chain and its length
    end
elseif sfcStatus == 2 %Manual SFC input
    S = 2;
	for i = 1 : S
        chain = input('Enter the SFCs as arrays');
		chainLength = size(chain)-1;
        sfcClassData(1,i) = SFC(chainLength(1,2)+1,chain,zeros(1,2),zeros(1,2));
	end
end

%% Generate the function parameters
lambda = zeros(S,F);
for s = 1 : S
	chain = sfcClassData(s).chain;
	chainLength = sfcClassData(s).chainLength;
	for c = 1 : chainLength
		lambda(s,chain(c)) = round(rand(1,1)*9+1);
	end
end
delta = zeros(S,F);
mu = ones(1,F);

%% VM hosting on the network
% [Xvn, vnMap, vmStatus, hostingStatus] = VMHost(N, V, VI, nodeStatus, vmTypes, vmCoreRequirements); %Sequential hosting
[VI, Xvn, vnMap, vmStatus, vmTypes] = greedyHosting(N, V, nodeStatus, vmCoreRequirements, Cvn); %greedy VM hosting

%% Array to store all node objects
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

%% Function deployment on the network
% [Xfv, fvMap, vnfStatus] = VNFDeploy(VI, F, FI, vmStatus, vmCoreRequirements, vnfTypes, vnfCoreRequirement); %Sequential deployment
% [Xfv, fvMap, vnfStatus] = greedyDeployment(N, VI, F, FI, inputNetwork, vnMap, vmStatus, vmCoreRequirements, vnfTypes) %Greedy algorithm when SFCs are not known
vnfTypes = zeros(1,F);
vnfFreq = zeros(1,F);
while min(vnfTypes) ~= 3
for i = 1 : S
        chain = randperm(F,lengths(i)) % Generate a random permutation as an SFC
        sfcClassData(1,i) = SFC(lengths(i),chain,zeros(1,2),zeros(1,2)); % Store the chain and its length
end
[FI, vnfTypes, vnfFreq] = generateVNFData(V, F, S, vmTypes, vmCoreRequirements, vnfCoreRequirement, sfcClassData);
lambda = zeros(S,F);
for s = 1 : S
	chain = sfcClassData(s).chain;
	chainLength = sfcClassData(s).chainLength;
	for c = 1 : chainLength
		lambda(s,chain(c)) = round(rand(1,1)*9+1);
	end
end
delta = zeros(S,F);
mu = ones(1,F);
end

vnfTypes



%%%%%%% UNCOMMENT AT NIGHT
% tic; % Starts the timer
% 
% % [Xfv, fvMap, vnfStatus, Xsf, sfcClassData, optCost] = bruteForceDeployment(N, VI, F, FI, S, L, Cvn, Xvn, Cfv, lambda, delta, mu, medium, network, bandwidths, nextHop, vmStatus, vnfTypes, sfcClassData, vnMap, vnfFreq, vmCoreRequirements, vnfCoreRequirement);
% % [Xfv, fvMap, vnfStatus, Xsf, sfcClassData, optCost] = metaHeuristicDeployment(N, VI, F, FI, S, L, Cvn, Xvn, Cfv, lambda, delta, mu, medium, network, bandwidths, nextHop, nodeStatus, vmStatus, vnfTypes, sfcClassData, vnMap, vnfFreq, vmCoreRequirements, vnfCoreRequirement, logFileID);
[Xfvi, fvMap, vnfStatus, Xsfi, Xllvi, sfcClassData, optCost, r] = reliableMetaHeuristicDeployment(N, VI, F, FI, S, L, alpha, Cvn, Xvn, Cfv, lambda, delta, mu, medium, inputNetwork, network, bandwidths, bridgeStatus, nextHop, nodeClassData, nodeStatus, vmStatus, vnfTypes, sfcClassData, vnMap, vnfFreq, vmCoreRequirements, vnfCoreRequirement, logFileID, inputFilePath, rhoNode, rhoVm, rhoVnf, 1);
% timer = toc % Stops the timer
% 
optCost
costOldGA(:,loop) = optCost;
% vnfStatus
% Xsfi


lengths = TreeMap();
for s = 1 : S
    chainLength = sfcClassData(s).chainLength;
    if ~lengths.containsKey(chainLength)
        lengths.put(chainLength,ArrayList());
    end
    lengths.get(chainLength).add(s);
end

sortedSfcClassData = SFC(1,S,zeros(1,2),zeros(1,2));
index = 1;
length = lengths.lastKey();
while size(length) > 0
    indices = lengths.get(length);
    if indices.size() == 0
        break;
    end
    length = lengths.lowerKey(length);
    listSize = indices.size();
    for i = 1 : listSize
        sortedSfcClassData(index) = sfcClassData(indices.get(i-1));
        index = index+1;
    end
end
sfcClassData = sortedSfcClassData;

% [Xfv, fvMap, vnfStatus, Xsf, sfcClassData, optCost] = bruteForceDeployment(N, VI, F, FI, S, L, Cvn, Xvn, Cfv, lambda, delta, mu, medium, network, bandwidths, nextHop, vmStatus, vnfTypes, sfcClassData, vnMap, vnfFreq, vmCoreRequirements, vnfCoreRequirement);
% [Xfv, fvMap, vnfStatus, Xsf, sfcClassData, optCost] = metaHeuristicDeployment(N, VI, F, FI, S, L, Cvn, Xvn, Cfv, lambda, delta, mu, medium, network, bandwidths, nextHop, nodeStatus, vmStatus, vnfTypes, sfcClassData, vnMap, vnfFreq, vmCoreRequirements, vnfCoreRequirement, logFileID);
[Xfvi, fvMap, vnfStatus, Xsfi, Xllvi, sfcClassData, optCost, r] = reliableMetaHeuristicDeployment(N, VI, F, FI, S, L, alpha, Cvn, Xvn, Cfv, lambda, delta, mu, medium, inputNetwork, network, bandwidths, bridgeStatus, nextHop, nodeClassData, nodeStatus, vmStatus, vnfTypes, sfcClassData, vnMap, vnfFreq, vmCoreRequirements, vnfCoreRequirement, logFileID, inputFilePath, rhoNode, rhoVm, rhoVnf, 2);

% fprintf(logFileID,'%f',timer); %This will print the time automatically

costNewGA(:,loop) = optCost; %%%%%%% UNCOMMENT AT NIGHT
% vnfStatus
% Xsfi



 %%%%%%% UNCOMMENT AT NIGHT
end
costOldGA
costNewGA

costs = sortrows([costOldGA; costNewGA]');
costOldGA(:) = costs(:,1);
costNewGA(:) = costs(:,2);

figure;
plot(1:1:100,costOldGA(1,:));
hold on;
plot(1:1:100,costOldGA(2,:));
hold on;
plot(1:1:100,costOldGA(3,:));
hold on;
plot(1:1:100,costNewGA(1,:));
hold on;
plot(1:1:100,costNewGA(2,:));
hold on;
plot(1:1:100,costNewGA(3,:));
title('Comparison with existing GA (Newyork)');
xlabel('Observation number');
ylabel('Cost');
legend('Existing GA, r = 0','Existing GA, r = 1','Existing GA, r = 2','Proposed GA, r = 0','Proposed GA, r = 1','Proposed GA, r = 2');


%{
%% Arary to store all VM objects
vmClassData = VM(1,zeros(1,2)); %to store the VM status
vnfCount = sum(Xfvi(:,:,1)); %count the vnfs on each VM
for i = 1 : VI %for each VM instance
    vnfs = zeros(1,vnfCount(1,i)); %to store the exact VNF instances
    index = 1; %start the index
    for f = 1 : FI %for each VNF instance
        if (Xfvi(f,i,1) == 1) %if the instance is placed on ith VM
            vnfs(1,index) = f; %store in the array
            index = index+1; %increment the index
        end
    end
    vmClassData(1,i) = VM(vnfCount(1,i),vnfs); %create the VM object
end

%% SFC assignment on the network
% [Xsf, sfcClassData] = SFCAssign(F, FI, S, vnfTypes, sfcClassData, fvMap, vnMap);

% % Binary Variables
% Xfvi = Xfv; % for iota 0, this new binary variable boils down to the existing binary variable indicating the VNF deployment
% Xski = Xsf; % for iota 0, this new binary vairable boils down to the existing binary variable indicating the SFC assignment
% 
% fprintf('\n');
% fprintf('------------------------------------------Costs------------------------------------------\n');
% y1 = getY1(N, VI, FI, Cvn, Xvn, Cfv, Xfv, vmStatus, vnfStatus)
% y2 = getY2(VI, F, FI, S, lambda, delta, mu, Xfvi, Xski, vnfStatus)
% y3 = getY3(L, S, medium, network, bandwidths, nextHop, sfcClassData)
% y1+y2+y3


% end

fclose(logFileID);
preSumVnf = zeros(1,F);
for i = 2 : F
	preSumVnf(1,i) = vnfTypes(1,i-1)+preSumVnf(1,i-1);
end

%% Graph image generations
% dot commands
commands = "";
vmColor = ["lightblue","lightgreen","pink","lightgoldenrod","ivory2"];
vnfColor = ["slategray2","tan","lightcoral","palegreen","cyan3"];

%% Nodes to be used
nodeNames = strings(1,N);
for node = 1 : N %for each node
	% node
    nodeName = "";
    nodeName = nodeName+sprintf("%d",node)+"[style=filled"+newline;
    nodeName = nodeName+"label=<"+newline;
    nodeName = nodeName+"<TABLE BORDER=""0"" BGCOLOR=""gray"">"+newline;
    nodeName = nodeName+"<TR>"+newline;

    currNodeVmCount = nodeClassData(1,node).vmCount;
    currNodeVms = nodeClassData(1,node).vms;

    for v = 1 : currNodeVmCount %for each VM on the current node
    	currVmVnfCount = vmClassData(1,currNodeVms(1,v)).vnfCount;
    	currVmVnfs = vmClassData(1,currNodeVms(1,v)).vnfs;

    	nodeName = nodeName+"<TD>"+newline;
    	nodeName = nodeName+"<TABLE BORDER=""0"" BGCOLOR="""+vmColor(1,v)+""">"+newline;

    	for f = 1 : currVmVnfCount %for each VNF on the current VM
   			nodeName = nodeName+"<TR><TD PORT=""f"+sprintf("%d",currVmVnfs(1,f))+""" BGCOLOR="""+vmColor(1,v)+""">f<SUB>"+sprintf("%d",vnfStatus(1,currVmVnfs(1,f)))+"</SUB></TD></TR>"+newline;
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

while q.size() ~= 0
    qLen = q.size();
    rankData = rankData+newline+"{rank = same; ";
    for i = 1 : qLen
        node = q.remove();
        nodeData = nodeData+newline+nodeNames(1,node);
        rankData = sprintf("%s%d; ",rankData,node);
        for adj = 1 : N
            if inputNetwork(node,adj) ~= 0 && visited(1,adj) == 0
                q.add(adj);
                visited(1,adj) = 1;
            end
        end
    end
    rankData = rankData+"};";
end

for i = 1 : N
	for j = i+1 : N
		if (inputNetwork(i,j) ~= 0)
			linkData = linkData+newline+sprintf("%d",i)+" -> "+sprintf("%d",j)+"[label="""+sprintf("%d",inputNetwork(i,j))+""" dir = none]";
		end
	end
end

gvText = gvText+rankData;
gvText = gvText+nodeData;
gvText = gvText+linkData;
gvText = gvText+newline+"splines=false";
gvText = gvText+newline+"}";

fileID = fopen(sprintf("%s%s",outputFilePath,'gv/graphPrint.gv'),'w+');
commands = commands+"dot -Tpng gv/graphPrint.gv -o img/graph.png";
fprintf(fileID,"%s",gvText);
fclose(fileID);

%% SFC and SFC assignment print
for c = 1 : S
	gvText = "digraph G";
	gvText = gvText+newline+"{";
	gvText = gvText+newline+"ranksep = ""equally""";
	gvText = gvText+newline+"rankdir = LR";
	gvText = gvText+newline+"subgraph sfc";
	gvText = gvText+newline+"{";
	gvText = gvText+newline+"node [shape=circle]";

	rankData = "";
	nodeData = "";
	linkData = "";

	chainLength = sfcClassData(1,c).chainLength;
	chain = sfcClassData(1,c).chain;
	usedLinks = sfcClassData(1,c).usedLinks;
	usedInstances = sfcClassData(1,c).usedInstances;
	usedInstancesMap = TreeMap();
    for iota = 1 : r
        usedInstancesMap.put(iota,HashSet());
        for i = 1 : chainLength
		    usedInstancesMap.get(iota).add(usedInstances(i,iota));
        end
    end

    % For the SFC
	for node = 1 : chainLength-1
		rankData = rankData+newline+"{rank = same; ";
		rankData = sprintf("%s%s%d; ",rankData,'f',chain(1,node));
		rankData = rankData+"};";
		nodeData = nodeData+newline+sprintf("%s%d",'f',chain(1,node))+"[style=filled label=<f<SUB>"+chain(1,node)+"</SUB>> color=""slategray2""]";
		linkData = linkData+newline+sprintf("%s%d",'f',chain(1,node))+" -> "+sprintf("%s%d",'f',chain(1,node+1));
	end

	% For the network graph
	rankData = rankData+newline+"{rank = same; ";
	rankData = sprintf("%s%s%d; ",rankData,'f',chain(1,chainLength));
	rankData = rankData+"};";
	nodeData = nodeData+newline+sprintf("%s%d",'f',chain(1,chainLength))+"[style=filled label=<f<SUB>"+chain(1,chainLength)+"</SUB>> color=""slategray2""]";
	gvText = gvText+rankData;
	gvText = gvText+nodeData;
	gvText = gvText+linkData;
	gvText = gvText+newline+"}";
	gvText = gvText+newline+"subgraph network";
	gvText = gvText+newline+"{";
	gvText = gvText+newline+"node [shape=none]";
	
	rankData = "";
	nodeData = "";
	linkData = "";

	import java.util.LinkedList;

	visited = zeros(1,N);
	q = LinkedList();
	q.add(1);
	visited(1,1) = 1;
	
	% BFS for node ranking
	while q.size() ~= 0
	    qLen = q.size();
	    rankData = rankData+newline+"{rank = same; ";
	    for i = 1 : qLen
	        node = q.remove();
	        rankData = sprintf("%s%d; ",rankData,node);
	        for adj = 1 : N
	            if inputNetwork(node,adj) ~= 0 && visited(1,adj) == 0 %if the link is connected in the original graph and not visited
	                q.add(adj); %add to queue
	                visited(1,adj) = 1; %mark as visited
	            end
	        end
	    end
	    rankData = rankData+"};";
	end

	nodeNames = strings(1,N); % This will contain the node definitions
	for node = 1 : N %for each node
	    nodeName = "";
	    nodeName = nodeName+sprintf("%d",node)+"[style=filled"+newline;
	    nodeName = nodeName+"label=<"+newline;
	    nodeName = nodeName+"<TABLE BORDER=""0"" BGCOLOR=""gray"">"+newline;
	    nodeName = nodeName+"<TR>"+newline;

	    currNodeVmCount = nodeClassData(1,node).vmCount;
	    currNodeVms = nodeClassData(1,node).vms;

	    for v = 1 : currNodeVmCount %for each VM on the current node
	    	currVmVnfCount = vmClassData(1,currNodeVms(1,v)).vnfCount;
	    	currVmVnfs = vmClassData(1,currNodeVms(1,v)).vnfs;

	    	nodeName = nodeName+"<TD>"+newline;
	    	nodeName = nodeName+"<TABLE BORDER=""0"" BGCOLOR=""darkgray"">"+newline;

	    	for f = 1 : currVmVnfCount %for each VNF on the current VM
	    		isColored = 0;
	    		for iota = 1 : r
	    			if usedInstancesMap.get(iota).contains(currVmVnfs(1,f))
	    				isColored = 1;
	   					nodeName = nodeName+"<TR><TD PORT=""f"+sprintf("%d",currVmVnfs(1,f))+""" BGCOLOR="""+vnfColor(iota)+""">f<SUB>"+sprintf("%d",vnfStatus(1,currVmVnfs(1,f)))+"</SUB></TD></TR>"+newline;
	   				end
	   			end
	   			if isColored == 0	
	   				nodeName = nodeName+"<TR><TD PORT=""f"+sprintf("%d",currVmVnfs(1,f))+""" BGCOLOR=""darkgray"">f<SUB>"+sprintf("%d",vnfStatus(1,currVmVnfs(1,f)))+"</SUB></TD></TR>"+newline;
	    		end
	    	end
	    	
	    	nodeName = nodeName+"</TABLE>"+newline;
	    	nodeName = nodeName+"</TD>"+newline;
	    end

	    nodeName = nodeName+"</TR>"+newline;
	    nodeName = nodeName+"</TABLE>>]"+newline;

	    nodeNames(1,node) = nodeName;
	end

	visitedEdge = zeros(N,N);
	visitedNode = zeros(1,N);
    for link = 1 : chainLength-1 %for each link in the usedlinks
		currSrc = usedLinks(link,1); %get the source
		currDest = usedLinks(link+1,1); %get the destination
		startNode = currSrc; %mark source as starting node
		nodeData = nodeData+newline+nodeNames(1,currSrc); %add into node data with black color
		visitedNode(1,currSrc) = 1; %mark source as visited
        while (startNode ~= currDest) %till starting node becomes equal to the destination
			uNode = startNode; %get the current node
			vNode = nextHop(startNode,currDest); %get the next hop node
			linkData = linkData+newline+sprintf("%d",uNode)+" -> "+sprintf("%d",vNode)+"[label="""+sprintf("%d",inputNetwork(uNode,vNode))+""" color=""black"" penwidth=2]"; %include the link data with black color
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
			if (inputNetwork(i,j) ~= 0) %if the edge exists in the original network
				if (visitedNode(1,i) ~= 1) %if ith node is not already visited
					nodeData = nodeData+newline+nodeNames(1,i); %include in gray color
					visitedNode(1,i) = 1; %mark as visited
				end
				if (visitedNode(1,j) ~= 1) %if ith node is not already visited
					nodeData = nodeData+newline+nodeNames(1,j); %include in gray color
					visitedNode(1,j) = 1; %mark as visited
				end
				if (visitedEdge(i,j) ~= 1) %if the edge between them is not visited
					linkData = linkData+newline+sprintf("%d",i)+" -> "+sprintf("%d",j)+"[label="""+sprintf("%d",inputNetwork(i,j))+""" color=""gray"" fontcolor=""gray"" dir = none]"; %include in gray color
					visitedEdge(i,j) = 1; %mark as visited
					visitedEdge(j,i) = 1; %mark as visited
				end
			end
		end
	end

	gvText = gvText+rankData;
	gvText = gvText+nodeData;
	gvText = gvText+linkData;
	gvText = gvText+newline+"}";
	gvText = gvText+newline+"splines=false";
	for node = 1 : chainLength
		gvText = gvText+newline+"f"+sprintf("%d",chain(node))+" -> "+sprintf("%d",usedLinks(node))+"[color=""slategray3"" style=dashed constraint=false]";
	end
	gvText = gvText+newline+"}";

	fileID = fopen(sprintf('%s%s%d%s',outputFilePath,'gv/sfcAssgn',c,'.gv'),'w+');
	commands = commands+newline+"dot -Tpng "+sprintf('%s%d%s','gv/sfcAssgn',c,'.gv')+" -o "+sprintf('%s%d%s','img/sfcAssgn',c,'.png');
	fprintf(fileID,"%s",gvText);
	fclose(fileID);
end

fileID = fopen(sprintf("%s%s",outputFilePath,'commands.bat'),'w+');
fprintf(fileID,"%s",commands);
fclose(fileID);

%}
% end