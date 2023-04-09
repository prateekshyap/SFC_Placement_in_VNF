function [cost, vmGene, XfviTemp, XsfiTemp, sfcClassData, vmCapacityTemp, vnfCapacityTemp] = calculateReliableFitnessValue(N, VI, F, FI, L, Cvn, Xvn, Cfv, Xfvi, Xsfi, Xllvi, lambda, delta, mu, medium, network, bandwidths, bridgeStatus, nextHop, vmStatus, vnfTypes, vnfStatus, sfcClassData, vnMap, vmCapacity, vnfCapacity, preSumVnf, sIndex, nodeGene, vmGene, r, nodeClassData)

	XfviTemp = Xfvi; % Create a copy of Xfvi for modification
	XsfiTemp = Xsfi; % Create a copy of Xsfi for modification
	XsfiTemp(sIndex,:,:) = zeros(FI,r); % Add a new block for the current SFC
	XllviTemp = Xllvi; % Create a copy of Xllvi for modification
	XllviTemp(sIndex,:,:,:,:) = repmat(0,[FI,FI,N,N]); % Add a new matrix for the current SFC
	vmCapacityTemp = vmCapacity; % Create a copy of VM Capacity for modification
	vnfCapacityTemp = vnfCapacity; % Create a copy of VNF Capacity for modification
	chain = sfcClassData(sIndex).chain; % Get the current chain
	chainLength = sfcClassData(sIndex).chainLength; % Get the current chain length
    usedLinks = zeros(1,chainLength); % To store the sequence of physical nodes
    nodeMaps = zeros(1,chainLength); % To store the sequence of function instances

    %% No Failure
	for pos = 1 : chainLength % For each VNF in the current chain
		chosenVM = vmGene(pos,1); % Get the chosen VM for the first level
		chosenNode = nodeGene(pos,1); % Get the chosen node for the first level
		fIndex = preSumVnf(chain(pos))+1; % Get the first instance
		indicator = 0;
		chosenInstance = 0;
		%% Step 1 - Find if an instance is already deployed on any VM on the chosen node
		vmList = nodeClassData(chosenNode).vms; % Get the list of VMs
		vmCount = nodeClassData(chosenNode).vmCount; % Get the count
		for fin = fIndex : fIndex+vnfTypes(chain(pos))-1 % For each instance of the same function
			for vin = 1 : vmCount % For each VM
				if XfviTemp(fin,vmList(vin)) == 1 % If the current instance is already hosted on the current VM
					indicator = 1; % Mark it
					chosenInstance = fin; % Store the index of the chosen instance
					chosenVM = vmList(vin); % Store the index of the chosen VM
					break;
				end
			end
		end
		if indicator == 1 && vnfCapacityTemp(chosenInstance) > 0 % If the chosen VM has an instance of the required VNF
            XfviTemp(chosenInstance,chosenVM,1) = 1; % Deploy
			XsfiTemp(sIndex,chosenInstance,1) = 1; % Assign
			vmGene(pos,1) = chosenVM; % Modify the vm gene (note that it will remain unmodified if already present)
            usedLinks(pos) = vnMap.get(vmGene(pos,1)); % Store the physical node
            nodeMaps(pos) = chosenInstance; % Store the instance number
			vnfCapacityTemp(chosenInstance) = vnfCapacityTemp(chosenInstance)-1; % Decrease the capacity
		else % If the assignment couldn't be done, we need to find another instance and assignment
			%% Step 2 - Find an undeployed instance to deploy on any VM on the chosen node
			freeVNF = 0;
			for fin = fIndex : fIndex+vnfTypes(chain(pos))-1 % For each instance of the same function
				indicator = 0;
				vIndex = 0;
				for vin = 1 : VI % For each VM instance
					if XfviTemp(fin,vin,1) == 1 % If the current instance is hosted on some VM
						indicator = 1; % Mark it
						vIndex = vin; % Store the corresponding VM index
						break;
					end
				end
				if indicator == 0 % If the current instance is not deployed anywhere
					freeVNF = fin; % Store it
					break;
				end
            end
			if freeVNF ~= 0 % If we got an undeployed VNF instance
				% Check if there is any free VM on the chosen node or not
				indicator = 0;
				chosenVM = 0;
				for vin = 1 : vmCount % For each VM
					if vmCapacityTemp(vmList(vin)) > 0 % If the current VM is free
						indicator = 1; % Mark it
						chosenVM = vmList(vin); % Store it
					end
				end
				if indicator == 1 % If the there exists a VM with such conditions
					XfviTemp(freeVNF,chosenVM,1) = 1; % Deploy
					XsfiTemp(sIndex,freeVNF,1) = 1; % Assign
					vmGene(pos,1) = chosenVM; % Modify the vm gene (note that it will remain unmodified if already present)
	                usedLinks(pos) = vnMap.get(vmGene(pos,1)); % Store the physical node
                    nodeMaps(pos) = freeVNF; % Store the instance number
	                vmCapacityTemp(chosenVM) = vmCapacityTemp(chosenVM)-1; % Decrease the capacity
	                vnfCapacityTemp(freeVNF) = vnfCapacityTemp(freeVNF)-1; % Decrease the capacity
	            else % If no such VM found, choose another free VM to deploy that instance
	            	%% Step 3 - Choose the closest free VM to deploy this instance
	            	% Please note that the capacity of the VM is calculated according to the total number of
	            	% VNF instances present, if you are changing the strategy to calculate the capacity, then
	            	% this step might break, change the logic accordingly
	            	minDistance = Inf; % This will store the the minimum distance
                    minDistanceVM = 0; % This will store the VM with the minimum distance
	            	for vin = 1 : VI % For each instance
	            		distance = network(chosenNode,vnMap.get(vin)); % Store the shortest distance from the chosen VM
	            		if distance < minDistance && vmCapacityTemp(vin) > 0
	            			minDistanceVM = vin; % Update the new VM
                            minDistance = distance; % Update the new minimum distance
	            		end
                    end
	            	XfviTemp(freeVNF,minDistanceVM,1) = 1; % Deploy
					XsfiTemp(sIndex,freeVNF,1) = 1; % Assign
					vmGene(pos,1) = minDistanceVM; % Modify the vm gene
                    usedLinks(pos) = vnMap.get(vmGene(pos,1)); % Store the physical node
                    nodeMaps(pos) = freeVNF; % Store the instance number
	                vmCapacityTemp(minDistanceVM) = vmCapacityTemp(minDistanceVM)-1; % Decrease the capacity
	                vnfCapacityTemp(freeVNF) = vnfCapacityTemp(freeVNF)-1; % Decrease the capacity
	            end
			else % If no such instance could be found i.e. all the corresponding instances are deployed
				%% Step 4 - Choose the closest instance to assign
                minDistanceInstance = 0;
                minDistance = Inf;
				for fin = fIndex : fIndex+vnfTypes(chain(pos))-1 % For each instance of the same function
                    if vnfCapacityTemp(fin) > 0 % If it has more capacity
                        chosenVM = 0;
						for vin = 1 : VI % For each VM
							if XfviTemp(fin,vin) == 1 % If required VM is spotted
								chosenVM = vin; % Store it
								break;
							end
						end
                        distance = network(vnMap.get(chosenVM),chosenNode);
                        if distance < minDistance
                            minDistanceInstance = fin;
                            minDistance = distance;
                        end
					end
                end
				XfviTemp(minDistanceInstance,chosenVM,1) = 1; % Deploy
				XsfiTemp(sIndex,minDistanceInstance,1) = 1; % Assign
				vmGene(pos,1) = chosenVM; % Modify the vm gene
                usedLinks(pos) = vnMap.get(vmGene(pos,1)); % Store the physical node
                nodeMaps(pos) = minDistanceInstance; % Store the instance number
                vnfCapacityTemp(minDistanceInstance) = vnfCapacityTemp(minDistanceInstance)-1; % Decrease the capacity
				% break;
			end
        end
    end

    sfcClassData(sIndex).usedLinks = usedLinks; % Store the physical nodes
    nodeGene = usedLinks; % Store it in the node gene as well
    sfcClassData(sIndex).nodeMaps = nodeMaps; % Store the instance indices
    for e = 1 : chainLength-1 % For each edge in the SFC
    	startNode = usedLinks(1,e); % Get the source
    	finalNode = usedLinks(1,e+1); % Get the destination
        while startNode ~= finalNode % Till we reach the destination
        	uNode = startNode; % Current node
        	vNode = nextHop(startNode,finalNode); % Next hop node
        	XllviTemp(sIndex,nodeMaps(e),nodeMaps(e+1),uNode,vNode) = 1;
        	XllviTemp(sIndex,nodeMaps(e),nodeMaps(e+1),vNode,uNode) = 1;
        	startNode = nextHop(startNode,finalNode); % Update the start node
        end
    end

    %% Failure


	y1 = getY1(N, VI, FI, Cvn, Xvn, Cfv, XfviTemp, vmStatus, vnfStatus);
	y2 = getY2(VI, F, FI, sIndex, lambda, delta, mu, XfviTemp, XsfiTemp, vnfStatus);
	y3 = getY3(L, sIndex, medium, network, bandwidths, nextHop, sfcClassData);

	cost = y1+y2+y3;
   
end