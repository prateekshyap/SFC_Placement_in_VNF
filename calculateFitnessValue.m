function [cost] = calculateFitnessValue(N, VI, F, FI, S, L, Cvn, Xvn, Cfv, Xfv, Xsf, lambda, delta, mu, medium, network, bandwidths, nextHop, nodeStatus, vmStatus, vnfTypes, vnfStatus, sfcClassData, vnMap, vnfFreq, vmCoreRequirements, vnfCoreRequirement, nodeCapacity, vmCapacity, vnfCapacity, preSumVnf, iterations, populationSize, sIndex, vmGene, nodeGene)

	XfvTemp = Xfv; % Create a copy of Xfv for modification
	XsfTemp = Xsf; % Create a copy of Xsf for modification
	XsfTemp(sIndex,:) = zeros(1,FI); % Add a new row
	chain = sfcClassData(sIndex).chain; % Get the current chain
	chainLength = sfcClassData(sIndex).chainLength; % Get the current chain length
    usedLinks = zeros(1,chainLength); % To store the sequence of physical nodes
    nodeMaps = zeros(1,chainLength); % To store the sequence of functio instances
	for pos = 1 : chainLength % For each VNF in the current chain
		chosenVM = vmGene(pos); % Get the chosen VM
		fIndex = preSumVnf(chain(pos))+1; % Get the first instance
		indicator = 0;
		chosenInstance = 0;
		% Step 1 - Find if an instance is already deployed on that VM
		for fin = fIndex : fIndex+vnfTypes(chain(pos))-1 % For each instance of the same function
			if XfvTemp(fin,chosenVM) == 1 % If the current instance is already hosted on the chosen VM
				indicator = 1; % Mark it
				chosenInstance = fin; % Store the index of the chosen instance
				break;
			end
		end
		if indicator == 1 && vnfCapacity(chosenInstance) > 0 % If the chosen VM has an instance of the required VNF
			XfvTemp(chosenInstance,chosenVM) = 1; % Deploy
			XsfTemp(sIndex,chosenInstance) = 1; % Assign
            nodeMaps(pos) = chosenInstance; % Store the instance number
			% Decrease the capacity
		else % If the assignment couldn't be done, we need to find another instance and assignment
			% Step 2 - Find an undeployed instance to deploy on that VM
			freeVNF = 0;
			for fin = fIndex : fIndex+vnfTypes(chain(pos))-1 % For each instance of the same function
				indicator = 0;
				vIndex = 0;
				for vin = 1 : VI % For each VM instance
					if XfvTemp(fin,vin) == 1 % If the current instance is hosted on some VM
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
				XfvTemp(freeVNF,chosenVM) = 1; % Deploy
				XsfTemp(sIndex,freeVNF) = 1; % Assign
                nodeMaps(pos) = freeVNF; % Store the instance number
			else % If no such instance could be found
				% Step 3 - Choose a random instance to assign
				for fin = fIndex : fIndex+vnfTypes(chain(pos))-1 % For each instance of the same function
					if vnfCapacity(fin) > 0 % If it has more capacity
						chosenVM = 0;
						for vin = 1 : VI % For each VM
							if XfvTemp(fin,vin) == 1 % If required VM is spotted
								chosenVM = vin; % Store it
								break;
							end
						end
						XfvTemp(fin,chosenVM) = 1; % Deploy
						XsfTemp(sIndex,freeVNF) = 1; % Assign
                        nodeMaps(pos) = fin; % Store the instance number
						vmGene(pos) = chosenVM; % Modify the vm gene
						% nodeGene(pos) = vnMap.get(chosenVM); % Modify the node gene
						break;
					end
				end
			end
        end
    end
    
    % sfcClassData(sIndex).usedLinks = nodeGene;
    sfcClassData(sIndex).nodeMaps = nodeMaps;
	y1 = getY1(N, VI, FI, Cvn, Xvn, Cfv, XfvTemp, vmStatus, vnfStatus);
	y2 = getY2(VI, F, FI, sIndex, lambda, delta, mu, XfvTemp, XsfTemp, vnfStatus);
	y3 = getY3(L, sIndex, medium, network, bandwidths, nextHop, sfcClassData);

	cost = y1+y2+y3;
end