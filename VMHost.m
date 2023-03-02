function [Xvn, vnMap, vmStatus] = VMHost(N, V, VI, nodeStatus, vmTypes, vmCoreRequirements)
	import java.util.TreeMap;
	import java.util.ArrayList;
	Xvn = zeros(VI,N); %VIxN matrix to indicate whether a vm instance v is hosted on the node n or not
	vnMap = TreeMap(); %Map Version of Xvn
	vmStatus = zeros(1,VI); %This will indicate which instance is of which type
	totalAvailableCores = sum(nodeStatus); %Total number of available cores in the network
	totalRequiredCores = 0;
	for v = 1 : V %For each VM
	    totalRequiredCores = totalRequiredCores+vmTypes(1,v)*vmCoreRequirements(1,v); %Add to the total required cores
	end
	if totalRequiredCores > totalAvailableCores %If the required cores is more than the available cores
	    fprintf('All VMs cannot be hosted'); %Show error
	end
	coreCount = TreeMap();
	for c = 1 : N
		if coreCount.containsKey(nodeStatus(1,c)) == 0 %If the number of cores is not present as an entry
			coreCount.put(nodeStatus(1,c),ArrayList()); %Add an entry
		end
		coreCount.get(nodeStatus(1,c)).add(c); %Add to the map
	end
	vmIndex = 1; %Initialize
	for v = 1 : V %For each VM type
		instanceCount = vmTypes(1,v); %Required number of instances
		requiredCores = vmCoreRequirements(1,v); %Required number of cores
		for i = 1 : instanceCount %For each instance
			machineCores = requiredCores; %Store the required cores to machine cores
			if coreCount.containsKey(machineCores) == 0 %If machine cores is not available in the nodes
				machineCores = coreCount.higherEntry(machineCores).getKey(); %Get the node that is having the next higher number of cores
			end
			availableMachines = coreCount.get(machineCores); %Get the machines that are available for the required number of cores
			machine = availableMachines.get(0); %Get the node id
			availableMachines.remove(0); %Remove it from the available nodes list
			if availableMachines.size() == 0 %If the list becomes empty
				coreCount.remove(machineCores); %Remove the corresponding entry from the map
			end
			Xvn(vmIndex,machine) = 1; %Mark that the current instance is hosted on the current node
			vnMap.put(vmIndex,machine); %Add to map
			vmStatus(1,vmIndex) = v; %Store the VM status
			machineCores = machineCores-requiredCores; %Mark the cores as used
			if machineCores > 0 %If more cores are available
				if coreCount.containsKey(machineCores) == 0 %If the available cores is not present as an entry
					coreCount.put(machineCores,ArrayList()); %Add an entry
				end
	            coreCount.get(machineCores).add(machine); %Add to the map
	        end
			vmIndex = vmIndex+1; %Increment the index of the VM instances
	    end
	end
end