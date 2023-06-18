function [VI, Xvn, vnMap, vmStatus, vmTypes] = greedyHosting(N, V, nodeStatus, vmCoreRequirements, Cvn)
	global VMCombination;
    global VMCost;
    import java.util.HashMap;
    import java.util.TreeMap;
	import java.util.ArrayList;
    coreIndex = HashMap();
    len = size(vmCoreRequirements);
	for core = 1 : len(2)
        coreIndex.put(vmCoreRequirements(core),core); %It stores the map of the core to the index with respect to vmCoreRequirements
    end
    tempAlloc = zeros(N,V);
    for node = 1 : N %For each node
		totalCores = nodeStatus(node); %Total available cores on that node
		VMCost = Inf; %Store max in VMCost
		recurHost(totalCores,Cvn,vmCoreRequirements,1,0,zeros(1,1)); %Recursion call
		len = size(VMCombination);
        for i = 1 : len(2) %For each VM
            tempAlloc(node,coreIndex.get(VMCombination(i))) = tempAlloc(node,coreIndex.get(VMCombination(i)))+1; %Store the allocation
        end
    end
    vmTypes = sum(tempAlloc); %This stores the count of each VM type
    VI = sum(vmTypes); %This stores the total VM instances
	Xvn = zeros(VI,N); %VIxN matrix to indicate whether a vm instance v is hosted on the node n or not
	vnMap = TreeMap(); %Map Version of Xvn
	vmStatus = zeros(1,VI); %This will indicate which instance is of which type
    index = 1; %Initialize index to 1
    for v = 1 : V %For each VM type
        for node = 1 : N %For each node
            while tempAlloc(node,v) > 0
                Xvn(index,node) = 1; %Update Xvn
                vnMap.put(index,node); %Update vnMap
                vmStatus(index) = v; %Store VM status
                index = index+1; %Increment the index
                tempAlloc(node,v) = tempAlloc(node,v)-1; %Decrement the instance count
            end
        end
    end
end

function [] = recurHost(availableCores, Cvn, vmCoreRequirements, index, currCost, currComb)
	global VMCombination;
    global VMCost;
    if availableCores == 0 %If all cores are filled
		if currCost < VMCost %If the current cost is less than the global cost
			VMCost = currCost; %Update the current cost
			VMCombination = currComb; %Update the combination
		end
		return; %Return
	end
	len = size(vmCoreRequirements);
	for core = 1 : len(2) %For each VM size
		if vmCoreRequirements(core) <= availableCores %If the required number of cores are available
			currComb(index) = vmCoreRequirements(core); %Update the combination
			recurHost(availableCores-vmCoreRequirements(core),Cvn,vmCoreRequirements,index+1,currCost+Cvn(core),currComb); %Recursion call
			currComb(index) = 0; %Backtrack
		end
	end
end