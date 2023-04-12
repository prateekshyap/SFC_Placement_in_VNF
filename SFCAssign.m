function [Xsf, sfcClassData] = SFCAssign(F, FI, S, vnfTypes, sfcClassData, fvMap, vnMap)
	Xsf = zeros(S,FI);
	preSumVnf = zeros(1,F);
	for i = 2 : F
		preSumVnf(i) = vnfTypes(i-1)+preSumVnf(i-1);
	end
	for s = 1 : S % For each SFC
		chainLength = sfcClassData(s).chainLength; % Get the chain length
		chain = sfcClassData(s).chain; % Get the chain
		usedLinks = zeros(1,chainLength); % To store the sequence of physical nodes
		usedInstances = zeros(1,chainLength); % To store the sequence of function instances
		for c = 1 : chainLength % For each node
			f = chain(c); % Get the required function
			availableVMs = fvMap.get(f); % Get the available VMs
			chosenVM = availableVMs.get(0); % Pick the first VM
			Xsf(s,preSumVnf(f)+chosenVM(1)) = 1; % Mark as assigned
			availableVMs.remove(0); % Remove it from the list
			availableVMs.add(chosenVM); % Add it to the end
			chosenNode = vnMap.get(chosenVM(2)); % Get the physical node
			usedLinks(c) = chosenNode; % Store to the array
			usedInstances(c) = preSumVnf(f)+chosenVM(1); % Store the corresponding function instance
		end
		sfcClassData(s).usedLinks = usedLinks; % Store to the class
		sfcClassData(s).usedInstances = usedInstances; % Store to the class
	end
end