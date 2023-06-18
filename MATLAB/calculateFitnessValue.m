function [cost, vmGene, XfvTemp, XsfTemp, sfcClassData, vmCapacityTemp, vnfCapacityTemp] = calculateFitnessValue(N, VI, F, FI, L, Cvn, Xvn, Cfv, Xfv, Xsf, lambda, delta, mu, medium, network, bandwidths, nextHop, vmStatus, vnfTypes, vnfStatus, sfcClassData, vnMap, vmCapacity, vnfCapacity, preSumVnf, sIndex, vmGene)

	XfvTemp = Xfv; % Create a copy of Xfv for modification
	XsfTemp = Xsf; % Create a copy of Xsf for modification
	XsfTemp(sIndex,:) = zeros(1,FI); % Add a new row
	vmCapacityTemp = vmCapacity; % Create a copy of VM Capacity for modification
	vnfCapacityTemp = vnfCapacity; % Create a copy of VNF Capacity for modification
	chain = sfcClassData(sIndex).chain; % Get the current chain
	chainLength = sfcClassData(sIndex).chainLength; % Get the current chain length
    usedLinks = zeros(1,chainLength); % To store the sequence of physical nodes
    nodeMaps = zeros(1,chainLength); % To store the sequence of functio instances
	for pos = 1 : chainLength % For each VNF in the current chain
		chosenVM = vmGene(pos); % Get the chosen VM
		fIndex = preSumVnf(chain(pos))+1; % Get the first instance
		indicator = 0;
		chosenInstance = 0;
		%% Step 1 - Find if an instance is already deployed on that VM
		for fin = fIndex : fIndex+vnfTypes(chain(pos))-1 % For each instance of the same function
			if XfvTemp(fin,chosenVM) == 1 % If the current instance is already hosted on the chosen VM
				indicator = 1; % Mark it
				chosenInstance = fin; % Store the index of the chosen instance
				break;
			end
		end
		if indicator == 1 && vnfCapacityTemp(chosenInstance) > 0 % If the chosen VM has an instance of the required VNF
            XfvTemp(chosenInstance,chosenVM) = 1; % Deploy
			XsfTemp(sIndex,chosenInstance) = 1; % Assign
            usedLinks(pos) = vnMap.get(vmGene(pos)); % Store the physical node
            nodeMaps(pos) = chosenInstance; % Store the instance number
			vnfCapacityTemp(chosenInstance) = vnfCapacityTemp(chosenInstance)-1; % Decrease the capacity
		else % If the assignment couldn't be done, we need to find another instance and assignment
			%% Step 2 - Find an undeployed instance to deploy on that VM
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
				if vmCapacityTemp(chosenVM) > 0 % If the chosen VM has more capacity
					XfvTemp(freeVNF,chosenVM) = 1; % Deploy
					XsfTemp(sIndex,freeVNF) = 1; % Assign
	                usedLinks(pos) = vnMap.get(vmGene(pos)); % Store the physical node
                    nodeMaps(pos) = freeVNF; % Store the instance number
	                vmCapacityTemp(chosenVM) = vmCapacityTemp(chosenVM)-1; % Decrease the capacity
	                vnfCapacityTemp(freeVNF) = vnfCapacityTemp(freeVNF)-1; % Decrease the capacity
	            else % If the VM is not free, choose another free VM to deploy that instance
	            	%% Step 3 - Choose the closest free VM to deploy this instance
	            	% Please note that the capacity of the VM is calculated according to the total number of
	            	% VNF instances present, if you are changing the strategy to calculate the capacity, then
	            	% this step might break, change the logic accordingly
                    distances = zeros(1,VI);
	            	minDistance = Inf; % This will store the the minimum distance
                    minDistanceVM = 0; % This will store the VM with the minimum distance
	            	for vin = 1 : VI % For each instance
	            		distances(vin) = network(vnMap.get(chosenVM),vnMap.get(vin)); % Store the shortest distance from the chosen VM
	            		if distances(vin) < minDistance && vin ~= chosenVM && vmCapacityTemp(vin) > 0
	            			minDistanceVM = vin; % Update the new VM
                            minDistance = distances(vin); % Update the new minimum distance
	            		end
                    end
	            	XfvTemp(freeVNF,minDistanceVM) = 1; % Deploy
					XsfTemp(sIndex,freeVNF) = 1; % Assign
					vmGene(pos) = minDistanceVM; % Modify the vm gene
                    usedLinks(pos) = vnMap.get(vmGene(pos)); % Store the physical node
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
							if XfvTemp(fin,vin) == 1 % If required VM is spotted
								chosenVM = vin; % Store it
								break;
							end
						end
                        distance = network(vnMap.get(chosenVM),vnMap.get(vmGene(pos)));
                        if distance < minDistance
                            minDistanceInstance = fin;
                            minDistance = distance;
                        end
					end
                end
				XfvTemp(minDistanceInstance,chosenVM) = 1; % Deploy
				XsfTemp(sIndex,minDistanceInstance) = 1; % Assign
				vmGene(pos) = chosenVM; % Modify the vm gene
                usedLinks(pos) = vnMap.get(vmGene(pos)); % Store the physical node
                nodeMaps(pos) = minDistanceInstance; % Store the instance number
                vnfCapacityTemp(minDistanceInstance) = vnfCapacityTemp(minDistanceInstance)-1; % Decrease the capacity
				% break;
			end
        end
    end

    sfcClassData(sIndex).usedLinks = usedLinks; % Store the physical nodes
    sfcClassData(sIndex).nodeMaps = nodeMaps; % Store the instance indices
	y1 = getY1(N, VI, FI, Cvn, Xvn, Cfv, XfvTemp, vmStatus, vnfStatus);
	y2 = getY2(VI, F, FI, sIndex, lambda, delta, mu, XfvTemp, XsfTemp, vnfStatus);
	y3 = getY3(L, sIndex, medium, network, bandwidths, nextHop, sfcClassData);

	cost = y1+y2+y3;
end