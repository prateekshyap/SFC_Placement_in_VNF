function [Xfv, fvMap, vnfStatus] = VNFDeploy(N, VI, F, FI, vmStatus, vmCoreRequirements, vnfTypes, vnfCoreRequirement)
	import java.util.TreeMap;
	import java.util.ArrayList;
	Xfv = zeros(FI,VI); %FIxVI matrix to indicate whether a vnf instance f is deployed on the VM v or not
	fvMap = TreeMap(); %Map version of Xfv
	vnfStatus = zeros(1,FI); %This will indicate which instance is of which type
	coreCount = TreeMap();
	preSumVnf = zeros(1,F);
	for i = 2 : F
		preSumVnf(1,i) = vnfTypes(1,i-1)+preSumVnf(1,i-1);
	end
	for v = 1 : VI
		if coreCount.containsKey(vmCoreRequirements(vmStatus(1,v))) == 0 %If the number of cores is not present as an entry
			coreCount.put(vmCoreRequirements(vmStatus(1,v)),ArrayList()); %Add an entry
		end
		coreCount.get(vmCoreRequirements(vmStatus(1,v))).add(v); %Add to the map
	end
	vnfIndex = 1; %Initialize
	for f = 1 : F %For each VNF type
		instanceCount = vnfTypes(1,f); %Required number of instances
		for i = 1 : instanceCount %For each instance
			VMCores = vnfCoreRequirement; %Store the required cores to VM cores
			if coreCount.containsKey(VMCores) == 0 %If VM cores is not available in the nodes
				VMCores = coreCount.higherEntry(VMCores).getKey(); %Get the node that is having the next higher number of cores
			end
			availableMachines = coreCount.get(VMCores); %Get the machines that are available for the required number of cores
			vMachine = availableMachines.get(0); %Get the node id
			availableMachines.remove(0); %Remove it from the available nodes list
			if availableMachines.size() == 0 %If the list becomes empty
				coreCount.remove(VMCores); %Remove the corresponding entry from the map
			end
			Xfv(vnfIndex,vMachine) = 1; %Mark that the current instance is hosted on the current node
			% fvMap.put(vnfIndex,vMachine); %Add to map
			if fvMap.containsKey(f) == 0
				fvMap.put(f,ArrayList());
			end
			fvMap.get(f).add([fvMap.get(f).size()+1 vMachine]);
			vnfStatus(1,vnfIndex) = f; %Store the VM status
			VMCores = VMCores-vnfCoreRequirement; %Mark the cores as used
			if VMCores > 0 %If more cores are available
				if coreCount.containsKey(VMCores) == 0 %If the available cores is not present as an entry
					coreCount.put(VMCores,ArrayList()); %Add an entry
				end
	            coreCount.get(VMCores).add(vMachine); %Add to the map
	        end
			vnfIndex = vnfIndex+1; %Increment the index of the VNF instances
	    end
	end
end

