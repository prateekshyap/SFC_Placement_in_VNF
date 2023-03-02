function [Xsf, sfcClassData] = SFCAssign(F, FI, S, vnfTypes, sfcClassData, fvMap, vnMap)
	Xsf = zeros(S,FI);
	preSumVnf = zeros(1,F);
	for i = 2 : F
		preSumVnf(1,i) = vnfTypes(1,i-1)+preSumVnf(1,i-1);
	end
	for s = 1 : S %For each SFC
		chainLength = sfcClassData(1,s).chainLength; %Get the chain length
		chain = sfcClassData(1,s).chain; %Get the chain
		usedLinks = zeros(1,chainLength); %To store the sequence of physical nodes
		nodeMaps = zeros(1,chainLength); %To store the sequence of function instances
		for c = 1 : chainLength %For each node
			f = chain(1,c); %Get the required function
			availableVMs = fvMap.get(f); %Get the available VMs
			chosenVM = availableVMs.get(0); %Pick the first VM
			Xsf(s,preSumVnf(1,f)+chosenVM(1)) = 1; %Mark as assigned
			availableVMs.remove(0); %Remove it from the list
			availableVMs.add(chosenVM); %Add it to the end
			chosenNode = vnMap.get(chosenVM(2)); %Get the physical node
			usedLinks(1,c) = chosenNode; %Store to the array
			nodeMaps(1,c) = preSumVnf(1,f)+chosenVM(1); %Store the corresponding function instance
		end
		sfcClassData(1,s).usedLinks = usedLinks; %Store to the class
		sfcClassData(1,s).nodeMaps = nodeMaps; %Store to the class
	end
end