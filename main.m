clear all
close all
clc

%{
%	VNFDeploy deploys the VNFs in ascending order of availability
%	greedyDeployment follows a greedy approach to deploy the VNFs
%}
global VMCombination;
global VMCost;

import java.util.TreeMap;
import java.util.HashSet;
import java.util.ArrayList;
import java.util.LinkedList;

%% Constants and Variables

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fileID = fopen('input/sevenReliabilityOne/constants.txt','r');
formatSpecifier = '%f';
dimension = [1,9];

constants = fscanf(fileID,formatSpecifier,dimension);

N = constants(1,1); %Number of nodes in the physical network
V = constants(1,2); %Types of VMs being considered
VI = 0; %Total number of VM instances
F = constants(1,3); %Types of VNFs being considered
FI = 0; %Total number of VNF instances
S = 0; %Total number of SFCs
vnfCoreRequirement = constants(1,4); %Required number of cores for each function
medium = constants(1,5); %Inverted Velocity depending on the transmission medium

% Failure Probabilities
rhoNode = constants(1,6); %Failure probability of nodes
rhoVm = constants(1,7); %Failure probability of VMs
rhoVnf = constants(1,8); %Failure probability of VNFs

% Other constants
L = constants(1,9); %Packet size
maximumCores = 64; %Maximum allowed cores on a physical node

fileID = fopen('input/sevenReliabilityOne/network.txt','r');
formatSpecifier = '%f';
dimension = [N,N];

inputNetwork = fscanf(fileID,formatSpecifier,dimension); %Physical network
for i = 1 : N
    for j = 1 : N
        if inputNetwork(i,j) ~= inputNetwork(j,i)
            fprintf('Incorrect Network at %d,%d',i,j);
        end
    end
end

[network,nextHop] = allPairShortestPath(N,inputNetwork); %Floyd-Warshall

fileID = fopen('input/sevenReliabilityOne/bandwidth.txt','r');
formatSpecifier = '%f';
dimension = [N,N];
bandwidths = fscanf(fileID,formatSpecifier,dimension); %Bandwidths of physical links

fileID = fopen('input/sevenReliabilityOne/nodeTypes.txt','r');
formatSpecifier = '%d';
dimension = [1,N];
nodeStatus = fscanf(fileID,formatSpecifier,dimension); %Type of nodes indicating the number of cores

fileID = fopen('input/sevenReliabilityOne/vmTypes.txt','r');
formatSpecifier = '%d';
dimension = [V,2];
temp = fscanf(fileID,formatSpecifier,dimension); %Type of VMs and their requirements
vmTypes = temp(1:V,1)';
vmCoreRequirements = temp(1:V,2)';
VI = sum(vmTypes);

fileID = fopen('input/sevenReliabilityOne/vnfTypes.txt','r');
formatSpecifier = '%d';
dimension = [1,F];
vnfTypes = fscanf(fileID,formatSpecifier,dimension); %Type of VNFs and their requirements
FI = sum(vnfTypes);

fileID = fopen('input/sevenReliabilityOne/costVN.txt','r');
formatSpecifier = '%f';
dimension = [1,V];
Cvn = fscanf(fileID,formatSpecifier,dimension); %Cost of hosting VMs on Nodes

% Cost of deploying VNFs on VMs
fileID = fopen('input/sevenReliabilityOne/costFV.txt','r');
formatSpecifier = '%f';
dimension = [1,F];
Cfv = fscanf(fileID,formatSpecifier,dimension); %Cost of deploying VNFs on VMs

% Failure level
iota = 0;

% Binary Variables
X = 0;

%% Array to store all SFC objects
sfcClassData = SFC(1,S,zeros(1,2),zeros(1,2));
sfcGraph = zeros(F,F);
sfcStatus = input('Choose one option for SFC:\n\t1. Random SFC Generation\n\t2. Custom Input\nEnter your choice:\n');
if sfcStatus == 1 %Random SFC generation
    S = input('Enter the number of SFCs:\n');
    lengths = input('Enter the lengths as an array:\n');
    for i = 1 : S
        chain = randperm(F,lengths(i));
        sfcClassData(1,i) = SFC(lengths(i),chain,zeros(1,2),zeros(1,2));
		sfcGraph(:,:,i) = zeros(F,F);
		for node = 1 : lengths(i)-1
			sfcGraph(chain(1,node),chain(1,node+1),i) = 1;
		end
    end
elseif sfcStatus == 2 %Manual SFC input
	S = input('Enter the number of SFCs:\n');
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
		sfcGraph(:,:,i) = zeros(F,F);
		for node = 1 : chainLength(1,2)
			sfcGraph(chain(1,node),chain(1,node+1),i) = 1;
		end
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
mu = ones(F);

%% VM hosting on the network
% [Xvn, vnMap, vmStatus, hostingStatus] = VMHost(N, V, VI, nodeStatus, vmTypes, vmCoreRequirements); %Sequential hosting
% if hostingStatus == 0 return; end
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
% [Xfv, fvMap, vnfStatus] = VNFDeploy(N, VI, F, FI, vmStatus, vmCoreRequirements, vnfTypes, vnfCoreRequirement); %Sequential deployment
[Xfv, fvMap, vnfStatus] = greedyDeployment(N, VI, F, FI, inputNetwork, vnMap, vmStatus, vmCoreRequirements, vnfTypes) %Greedy algorithm
%{
%% Arary to store all VM objects
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

%% SFC assignment on the network
[Xsf, sfcClassData] = SFCAssign(F, FI, S, vnfTypes, sfcClassData, fvMap, vnMap);

% Binary Variables
Xfvi = Xfv; % for iota 0, this new binary variable boils down to the existing binary variable indicating the VNF deployment
Xski = Xsf; % for iota 0, this new binary vairable boils down to the existing binary variable indicating the SFC assignment

y1 = getY1(N, VI, FI, Cvn, Xvn, Cfv, Xfv, vmStatus, vnfStatus);
y2 = getY2(VI, F, FI, S, lambda, delta, mu, Xfvi, Xski, vnfStatus);
y3 = getY3(L, S, medium, network, bandwidths, nextHop, sfcClassData);

preSumVnf = zeros(1,F);
for i = 2 : F
	preSumVnf(1,i) = vnfTypes(1,i-1)+preSumVnf(1,i-1);
end

%% Graph image generations
% dot commands
commands = "";
% vnfStatus = [1 1 1 2 2 3 3 3 4 4 4 4 5 5 5 6 6 6 7 7 8 8];
vmColor = ["lightblue","lightgreen","pink","lightgoldenrod","ivory2"];

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

fileID = fopen('output/sevenReliabilityOne/gv/graphPrint.gv','w+');
commands = commands+"dot -Tpng gv/graphPrint.gv -o img/graph.png";
fprintf(fileID,"%s",gvText);

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
	nodeMaps = sfcClassData(1,c).nodeMaps;
	nodeMapSet = HashSet();
	for i = 1 : chainLength
		nodeMapSet.add(nodeMaps(i));
	end

	for node = 1 : chainLength-1
		rankData = rankData+newline+"{rank = same; ";
		rankData = sprintf("%s%s%d; ",rankData,'f',chain(1,node));
		rankData = rankData+"};";
		nodeData = nodeData+newline+sprintf("%s%d",'f',chain(1,node))+"[style=filled label=<f<SUB>"+chain(1,node)+"</SUB>> color=""slategray2""]";
		linkData = linkData+newline+sprintf("%s%d",'f',chain(1,node))+" -> "+sprintf("%s%d",'f',chain(1,node+1));
	end

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

	nodeNames = strings(1,N);
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
	    		if nodeMapSet.contains(currVmVnfs(1,f))
	   				nodeName = nodeName+"<TR><TD PORT=""f"+sprintf("%d",currVmVnfs(1,f))+""" BGCOLOR=""slategray2"">f<SUB>"+sprintf("%d",vnfStatus(1,currVmVnfs(1,f)))+"</SUB></TD></TR>"+newline;
	   			else	
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
		currSrc = usedLinks(link); %get the source
		currDest = usedLinks(link+1); %get the destination
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

	fileID = fopen(sprintf('%s%d%s','output/sevenReliabilityOne/gv/sfcAssgn',c,'.gv'),'w+');
	commands = commands+newline+"dot -Tpng "+sprintf('%s%d%s','gv/sfcAssgn',c,'.gv')+" -o "+sprintf('%s%d%s','img/sfcAssgn',c,'.png');
	fprintf(fileID,"%s",gvText);
end

fileID = fopen('output/sevenReliabilityOne/commands.bat','w+');
fprintf(fileID,"%s",commands);
fclose(fileID);

%}





















%{

% %% SFC print
% for c = 1 : S
% 	gvText = "digraph G";
% 	gvText = gvText+newline+"{";
% 	gvText = gvText+newline+"ranksep = ""equally""";
% 	gvText = gvText+newline+"rankdir = LR";
% 	gvText = gvText+newline+"node [shape=circle]";

% 	rankData = "";
% 	nodeData = "";
% 	linkData = "";

% 	chainLength = sfcClassData(1,c).chainLength;
% 	chain = sfcClassData(1,c).chain;

% 	for node = 1 : chainLength-1
% 		rankData = rankData+newline+"{rank = same; ";
% 		rankData = sprintf("%s%s%d; ",rankData,'f',chain(1,node));
% 		rankData = rankData+"};";
% 		nodeData = nodeData+newline+sprintf("%s%d",'f',chain(1,node))+"[style=filled label=<f<SUB>"+chain(1,node)+"</SUB>> color=""bisque""]";
% 		linkData = linkData+newline+sprintf("%s%d",'f',chain(1,node))+" -> "+sprintf("%s%d",'f',chain(1,node+1));
% 	end

% 	rankData = rankData+newline+"{rank = same; ";
% 	rankData = sprintf("%s%s%d; ",rankData,'f',chain(1,chainLength));
% 	rankData = rankData+"};";
% 	nodeData = nodeData+newline+sprintf("%s%d",'f',chain(1,chainLength))+"[style=filled label=<f<SUB>"+chain(1,chainLength)+"</SUB>> color=""bisque""]";
% 	gvText = gvText+rankData;
% 	gvText = gvText+nodeData;
% 	gvText = gvText+linkData;
% 	gvText = gvText+newline+"}";

% 	fileID = fopen(sprintf('%s%d%s','output/sevenReliabilityOne/gv/sfc',c,'.gv'),'w+');
% 	commands = commands+newline+"dot -Tpng "+sprintf('%s%d%s','gv/sfc',c,'.gv')+" -o "+sprintf('%s%d%s','img/sfc',c,'.png');
% 	fprintf(fileID,"%s",gvText);
% end

% %% SFC assignment print
% for c = 1 : S
% 	chainLength = sfcClassData(1,c).chainLength;
% 	chain = sfcClassData(1,c).chain;
% 	usedLinks = sfcClassData(1,c).usedLinks;
% 	nodeMaps = sfcClassData(1,c).nodeMaps;
% 	nodeMapSet = HashSet();
% 	for i = 1 : chainLength
% 		nodeMapSet.add(nodeMaps(i));
% 	end
	
% 	nodeNames = strings(1,N);
% 	for node = 1 : N %for each node
% 	    nodeName = "";
% 	    nodeName = nodeName+sprintf("%d",node)+"[style=filled"+newline;
% 	    nodeName = nodeName+"label=<"+newline;
% 	    nodeName = nodeName+"<TABLE BORDER=""0"" BGCOLOR=""gray"">"+newline;
% 	    nodeName = nodeName+"<TR>"+newline;

% 	    currNodeVmCount = nodeClassData(1,node).vmCount;
% 	    currNodeVms = nodeClassData(1,node).vms;

% 	    for v = 1 : currNodeVmCount %for each VM on the current node
% 	    	currVmVnfCount = vmClassData(1,currNodeVms(1,v)).vnfCount;
% 	    	currVmVnfs = vmClassData(1,currNodeVms(1,v)).vnfs;

% 	    	nodeName = nodeName+"<TD>"+newline;
% 	    	nodeName = nodeName+"<TABLE BORDER=""0"" BGCOLOR=""darkgray"">"+newline;

% 	    	for f = 1 : currVmVnfCount %for each VNF on the current VM
% 	    		if nodeMapSet.contains(currVmVnfs(1,f))
% 	   				nodeName = nodeName+"<TR><TD PORT=""f"+sprintf("%d",currVmVnfs(1,f))+""" BGCOLOR=""bisque"">f<SUB>"+sprintf("%d",vnfStatus(1,currVmVnfs(1,f)))+"</SUB></TD></TR>"+newline;
% 	   			else	
% 	   				nodeName = nodeName+"<TR><TD PORT=""f"+sprintf("%d",currVmVnfs(1,f))+""" BGCOLOR=""darkgray"">f<SUB>"+sprintf("%d",vnfStatus(1,currVmVnfs(1,f)))+"</SUB></TD></TR>"+newline;
% 	    		end
% 	    	end
	    	
% 	    	nodeName = nodeName+"</TABLE>"+newline;
% 	    	nodeName = nodeName+"</TD>"+newline;
% 	    end

% 	    nodeName = nodeName+"</TR>"+newline;
% 	    nodeName = nodeName+"</TABLE>>]"+newline;

% 	    nodeNames(1,node) = nodeName;
% 	end

% 	gvText = "digraph G";
% 	gvText = gvText+newline+"{";
% 	gvText = gvText+newline+"ranksep = ""equally""";
% 	gvText = gvText+newline+"rankdir = LR";
% 	gvText = gvText+newline+"node [shape=none]";

% 	rankData = "";
% 	nodeData = "";
% 	linkData = "";

% 	import java.util.LinkedList;

% 	visited = zeros(1,N);
% 	q = LinkedList();
% 	q.add(1);
% 	visited(1,1) = 1;
	
% 	while q.size() ~= 0
% 	    qLen = q.size();
% 	    rankData = rankData+newline+"{rank = same; ";
% 	    for i = 1 : qLen
% 	        node = q.remove();
% 	        rankData = sprintf("%s%d; ",rankData,node);
% 	        for adj = 1 : N
% 	            if inputNetwork(node,adj) ~= 0 && visited(1,adj) == 0 %if the link is connected in the original graph and not visited
% 	                q.add(adj); %add to queue
% 	                visited(1,adj) = 1; %mark as visited
% 	            end
% 	        end
% 	    end
% 	    rankData = rankData+"};";
% 	end

% 	visitedEdge = zeros(N,N);
% 	visitedNode = zeros(1,N);
%     for link = 1 : chainLength-1 %for each link in the usedlinks
% 		currSrc = usedLinks(link); %get the source
% 		currDest = usedLinks(link+1); %get the destination
% 		startNode = currSrc; %mark source as starting node
% 		nodeData = nodeData+newline+nodeNames(1,currSrc); %add into node data with black color
% 		visitedNode(1,currSrc) = 1; %mark source as visited
%         while (startNode ~= currDest) %till starting node becomes equal to the destination
% 			uNode = startNode; %get the current node
% 			vNode = nextHop(startNode,currDest); %get the next hop node
% 			linkData = linkData+newline+sprintf("%d",uNode)+" -> "+sprintf("%d",vNode)+"[label="""+sprintf("%d",inputNetwork(uNode,vNode))+""" color=""black"" penwidth=2]"; %include the link data with black color
% 			visitedEdge(startNode,nextHop(startNode,currDest)) = 1; %mark edge as visited
% 			visitedEdge(nextHop(startNode,currDest),startNode) = 1; %mark edge as visited
% 			startNode = nextHop(startNode,currDest); %update the current node
%         end
%         if (visitedNode(1,currDest) ~= 1) %if the destination is not already visited
%             visitedNode(1,currDest) = 1; %mark destination node as visited
% 	        nodeData = nodeData+newline+nodeNames(1,currDest); %include destination node in black color
%         end
%     end
	
% 	for i = 1 : N
% 		for j = i+1 : N
% 			if (inputNetwork(i,j) ~= 0) %if the edge exists in the original network
% 				if (visitedNode(1,i) ~= 1) %if ith node is not already visited
% 					nodeData = nodeData+newline+nodeNames(1,i); %include in gray color
% 					visitedNode(1,i) = 1; %mark as visited
% 				end
% 				if (visitedNode(1,j) ~= 1) %if ith node is not already visited
% 					nodeData = nodeData+newline+nodeNames(1,j); %include in gray color
% 					visitedNode(1,j) = 1; %mark as visited
% 				end
% 				if (visitedEdge(i,j) ~= 1) %if the edge between them is not visited
% 					linkData = linkData+newline+sprintf("%d",i)+" -> "+sprintf("%d",j)+"[label="""+sprintf("%d",inputNetwork(i,j))+""" color=""gray"" fontcolor=""gray"" dir = none]"; %include in gray color
% 					visitedEdge(i,j) = 1; %mark as visited
% 					visitedEdge(j,i) = 1; %mark as visited
% 				end
% 			end
% 		end
% 	end

% 	gvText = gvText+rankData;
% 	gvText = gvText+nodeData;
% 	gvText = gvText+linkData;
% 	gvText = gvText+newline+"}";

% 	fileID = fopen(sprintf('%s%d%s','output/sevenReliabilityOne/gv/sfcAssgn',c,'.gv'),'w+');
% 	commands = commands+newline+"dot -Tpng "+sprintf('%s%d%s','gv/sfcAssgn',c,'.gv')+" -o "+sprintf('%s%d%s','img/sfcAssgn',c,'.png');
% 	fprintf(fileID,"%s",gvText);
% end

% fileID = fopen('output/sevenReliabilityOne/commands.bat','w+');
% fprintf(fileID,"%s",commands);
% fclose(fileID);


% % SFC print
% for c = 1 : S
% 	gvText = "digraph G";
% 	gvText = gvText+newline+"{";
% 	gvText = gvText+newline+"ranksep = ""equally""";
% 	gvText = gvText+newline+"rankdir = LR";
% 	gvText = gvText+newline+"node [shape=circle]";

% 	rankData = "";
% 	nodeData = "";
% 	linkData = "";

% 	chainLength = sfcClassData(1,c).chainLength;
% 	chain = sfcClassData(1,c).chain;

% 	for node = 1 : chainLength-1
% 		rankData = rankData+newline+"{rank = same; ";
% 		rankData = sprintf("%s%s%d; ",rankData,'f',chain(1,node));
% 		rankData = rankData+"};";
% 		nodeData = nodeData+newline+sprintf("%s%d",'f',chain(1,node))+"[style=filled label=<f<SUB>"+chain(1,node)+"</SUB>> color=""bisque""]";
% 		linkData = linkData+newline+sprintf("%s%d",'f',chain(1,node))+" -> "+sprintf("%s%d",'f',chain(1,node+1));
% 	end

% 	rankData = rankData+newline+"{rank = same; ";
% 	rankData = sprintf("%s%s%d; ",rankData,'f',chain(1,chainLength));
% 	rankData = rankData+"};";
% 	nodeData = nodeData+newline+sprintf("%s%d",'f',chain(1,chainLength))+"[style=filled label=<f<SUB>"+chain(1,chainLength)+"</SUB>> color=""bisque""]";
% 	gvText = gvText+rankData;
% 	gvText = gvText+nodeData;
% 	gvText = gvText+linkData;
% 	gvText = gvText+newline+"}";

% 	fileID = fopen(sprintf('%s%d%s','output/sevenReliabilityOne/gv/sfc',c,'.gv'),'w+');
% 	commands = commands+newline+"dot -Tpng "+sprintf('%s%d%s','gv/sfc',c,'.gv')+" -o "+sprintf('%s%d%s','img/sfc',c,'.png');
% 	fprintf(fileID,"%s",gvText);
% end


%}