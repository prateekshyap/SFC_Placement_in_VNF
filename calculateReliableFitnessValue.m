function [cost, nodeGene, vmGene, XfviTemp, XsfiTemp, XllviTemp, sfcClassData, vmCapacityTemp, vnfCapacityTemp] = calculateReliableFitnessValue(N, VI, F, FI, L, alpha, Cvn, Xvn, Cfv, Xfvi, Xsfi, Xllvi, lambda, delta, mu, medium, inputNetwork, network, bandwidths, bridgeStatus, nextHop, vmStatus, vnfTypes, vnfStatus, sfcClassData, vnMap, vmCapacity, vnfCapacity, preSumVnf, sIndex, nodeGene, vmGene, r, nodeClassData, rhoNode, rhoVm, rhoVnf, isFinal)

	import java.util.TreeSet;

	XfviTemp = Xfvi; % Create a copy of Xfvi for modification
	XsfiTemp = Xsfi; % Create a copy of Xsfi for modification
	XsfiTemp(sIndex,:,:) = zeros(FI,r); % Add a new block for the current SFC
% 	XllviTemp = Xllvi; % Create a copy of Xllvi for modification
% 	XllviTemp(sIndex,:,:,:,:,:) = zeros(FI,FI,N,N,r); % Add a new matrix for the current SFC
    XllviTemp = 0;
	vmCapacityTemp = vmCapacity; % Create a copy of VM Capacity for modification
	vnfCapacityTemp = vnfCapacity; % Create a copy of VNF Capacity for modification
	chain = sfcClassData(sIndex).chain; % Get the current chain
	chainLength = sfcClassData(sIndex).chainLength; % Get the current chain length
    usedLinks = zeros(chainLength,r); % To store the sequence of physical nodes
    usedInstances = zeros(chainLength,r); % To store the sequence of function instances

    %% No Failure
	for pos = 1 : chainLength % For each VNF in the current chain
        chosenVM = 0;
		chosenNode = nodeGene(pos,1); % Get the chosen node for the first level
		fIndex = preSumVnf(chain(pos))+1; % Get the first instance
		indicator = 0;
		chosenInstance = 0;
		%% Step 1 - Find if an instance is already deployed on any VM on the chosen node
		vmList = nodeClassData(chosenNode).vms; % Get the list of VMs
		vmCount = nodeClassData(chosenNode).vmCount; % Get the count
		for fin = fIndex : fIndex+vnfTypes(chain(pos))-1 % For each instance of the same function
			for vin = 1 : vmCount % For each VM
				if XfviTemp(fin,vmList(vin),1) == 1 % If the current instance is already deployed on the current VM
					indicator = 1; % Mark it
					chosenInstance = fin; % Store the index of the chosen instance
					chosenVM = vmList(vin); % Store the index of the chosen VM
					break;
				end
			end
		end
		if indicator == 1 && vnfCapacityTemp(1,chosenInstance) > 0 % If the chosen VM has an instance of the required VNF
			XsfiTemp(sIndex,chosenInstance,1) = 1; % Assign
			vmGene(pos,1) = chosenVM; % Modify the vm gene (note that it will remain unmodified if already present)
            usedLinks(pos) = vnMap.get(vmGene(pos,1)); % Store the physical node
            nodeGene(pos,1) = vnMap.get(vmGene(pos,1)); % Store the physical node
            usedLinks(pos,1) = nodeGene(pos,1);
            usedInstances(pos,1) = chosenInstance; % Store the instance number
			vnfCapacityTemp(1,chosenInstance) = vnfCapacityTemp(1,chosenInstance)-1; % Decrease the capacity
		else % If the assignment couldn't be done, we need to find another instance and assignment
			%% Step 2 - Find an undeployed instance to deploy on any VM on the chosen node
			freeVNF = 0;
			for fin = fIndex : fIndex+vnfTypes(chain(pos))-1 % For each instance of the same function
				indicator = 0;
				vIndex = 0;
				for vin = 1 : VI % For each VM instance
					if XfviTemp(fin,vin,1) == 1 % If the current instance is deployed on some VM
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
						break;
					end
				end
				if indicator == 1 % If the there exists a VM with such conditions
					XfviTemp(freeVNF,chosenVM,1) = 1; % Deploy
					XsfiTemp(sIndex,freeVNF,1) = 1; % Assign
					vmGene(pos,1) = chosenVM; % Modify the vm gene (note that it will remain unmodified if already present)
	                usedLinks(pos) = vnMap.get(vmGene(pos,1)); % Store the physical node
            		nodeGene(pos,1) = vnMap.get(vmGene(pos,1)); % Store the physical node
                    usedLinks(pos,1) = nodeGene(pos,1);
                    usedInstances(pos,1) = freeVNF; % Store the instance number
	                vmCapacityTemp(chosenVM) = vmCapacityTemp(chosenVM)-1; % Decrease the capacity
	                vnfCapacityTemp(1,freeVNF) = vnfCapacityTemp(1,freeVNF)-1; % Decrease the capacity
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
            		nodeGene(pos,1) = vnMap.get(vmGene(pos,1)); % Store the physical node
                    usedLinks(pos,1) = nodeGene(pos,1);
                    usedInstances(pos,1) = freeVNF; % Store the instance number
	                vmCapacityTemp(minDistanceVM) = vmCapacityTemp(minDistanceVM)-1; % Decrease the capacity
	                vnfCapacityTemp(1,freeVNF) = vnfCapacityTemp(1,freeVNF)-1; % Decrease the capacity
	            end
			else % If no such instance could be found i.e. all the corresponding instances are deployed
				%% Step 4 - Choose the closest instance to assign
                minDistance = Inf;
                minDistanceInstance = 0;
                minDistanceVM = 0;
				for fin = fIndex : fIndex+vnfTypes(chain(pos))-1 % For each instance of the same function
                    if vnfCapacityTemp(1,fin) > 0 % If it has more capacity
                        chosenVM = 0;
						for vin = 1 : VI % For each VM
							if XfviTemp(fin,vin,1) == 1 % If required VM is spotted
								chosenVM = vin; % Store it
								break;
							end
						end
                        distance = network(vnMap.get(chosenVM),chosenNode);
                        if distance < minDistance
                            minDistanceInstance = fin;
                            minDistance = distance;
                            minDistanceVM = chosenVM;
                        end
					end
                end
			    XsfiTemp(sIndex,minDistanceInstance,1) = 1; % Assign
			    vmGene(pos,1) = minDistanceVM; % Modify the vm gene
                usedLinks(pos) = vnMap.get(vmGene(pos,1)); % Store the physical node
        	    nodeGene(pos,1) = vnMap.get(vmGene(pos,1)); % Store the physical node
                usedLinks(pos,1) = nodeGene(pos,1);
                usedInstances(pos,1) = minDistanceInstance; % Store the instance number
                vnfCapacityTemp(1,minDistanceInstance) = vnfCapacityTemp(1,minDistanceInstance)-1; % Decrease the capacity
			end
        end
    end

    sfcClassData(sIndex).usedLinks = usedLinks; % Store the physical nodes
    sfcClassData(sIndex).usedInstances = usedInstances; % Store the instance indices
%     for e = 1 : chainLength-1 % For each edge in the SFC
%     	startNode = nodeGene(e,1); % Get the source
%     	finalNode = nodeGene(e+1,1); % Get the destination
%         while startNode ~= finalNode % Till we reach the destination
%         	uNode = startNode; % Current node
%         	vNode = nextHop(startNode,finalNode); % Next hop node
%         	XllviTemp(sIndex,usedInstances(e,1),usedInstances(e+1,1),uNode,vNode,1) = 1;
%         	XllviTemp(sIndex,usedInstances(e,1),usedInstances(e+1,1),vNode,uNode,1) = 1;
%         	startNode = nextHop(startNode,finalNode); % Update the start node
%         end
%     end

    %% Failure
    for iota = 2 : r % For the next levels of reliability
    	for pos = 1 : chainLength % For each chain position
    		failedNodes = TreeSet(); % This will store the nodes that are already used in previous levels
    		for l = 1 : iota-1 % For each previous level
                failedNodes.add(nodeGene(pos,l)); % Add the node that is used
            end
            while failedNodes.contains(nodeGene(pos,iota))
            	nodeGene(pos,iota) = randi(N);
            end
            currNodeVmCount = nodeClassData(nodeGene(pos,iota)).vmCount; % Get the VM count of the corresponding node from the node population
            currNodeVms = nodeClassData(nodeGene(pos,iota)).vms; % Get the list of VMs
            vmIndex = randi(currNodeVmCount); % Generate a random Index
            vmGene(pos,iota) = currNodeVms(vmIndex); % Store the corresponding VM in the vm population
            chosenVM = 0; % Get the chosen VM for iota
            chosenNode = nodeGene(pos,iota); % Get the chosen node for iota
            fIndex = preSumVnf(chain(pos))+1; % Get the first instance
            indicator = 0;
            chosenInstance = 0;
            %% Step 1 - Find if an instance is already deployed on any VM on the chosen node
            vmList = nodeClassData(chosenNode).vms; % Get the list of VMs
            vmCount = nodeClassData(chosenNode).vmCount; % Get the count
            for fin = fIndex : fIndex+vnfTypes(chain(pos))-1 % For each instance of the same function
            	for vin = 1 : vmCount % For each VM
            		% Note that in reality we can NOT deploy an instance in
                    % after a failure has occured. It is always the reverse
                    % case. We deploy all the instances and then only the
                    % failures occur. Hence, at any point if we want to
                    % check if an instance is deployed or not, we have to
                    % check for the NO FAILURE i.e. iota = 1. Because, an
                    % instance which is a backup for some SFC will deifnitely
                    % work as a primary assignment for some other SFC.
                    % Other iota matrices will remain unfilled and they'll
                    % only be filled when required
            		if XfviTemp(fin,vmList(vin),1) == 1 % If the current instance is already deployed on the current VM
            			indicator = 1; % Mark it
            			chosenInstance = fin; % Store the index of the chosen instance
            			chosenVM = vmList(vin); % Store the index of the chosen VM
            			break;
            		end
            	end
        		if indicator == 1
        			break;
        		end
            end
            if (indicator == 1) && vnfCapacityTemp(iota,chosenInstance) > 0 && (~failedNodes.contains(chosenNode)) % If the chosen VM has an instance of the required VNF and the chosen node is not already present in the previous reliability levels
            	XsfiTemp(sIndex,chosenInstance,iota) = 1; % This indicates that the chosen instance is going to be assigned as a backup at level iota
            	vmGene(pos,iota) = chosenVM; % Modify the vm gene
            	nodeGene(pos,iota) = vnMap.get(vmGene(pos,iota)); % Store the physical node
                usedLinks(pos,iota) = nodeGene(pos,iota);
            	usedInstances(pos,iota) = chosenInstance; % Store the instance
                vnfCapacityTemp(iota,chosenInstance) = vnfCapacityTemp(iota,chosenInstance)-1; % Decrease the capacity by 1
            else % If the node couldn't be chosen, we need to find another instance
            	%% Step 2 - Find an undeployed instance to deploy on any VM on the chosen node
            	freeVNF = 0;
            	isDeployed = 0;
            	for fin = fIndex : fIndex+vnfTypes(chain(pos))-1 % For each instance of the same function
            		indicator = 0;
            		vIndex = 0;
            		for vin = 1 : VI % For each VM instance
            			if XfviTemp(fin,vin,1) == 1 % If the current instance is deployed on some VM
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
            	if freeVNF ~= 0 % If we got an undeployed VM instance
            		% Check if there is any free VM on the chosen node or not
            		indicator = 0;
            		chosenVM = 0;
            		for vin = 1 : vmCount % For each VM
            			if vmCapacityTemp(vmList(vin)) > 0 % If the current VM is free
            				indicator = 1; % Mark it
            				chosenVM = vmList(vin); % Store it
            				break;
            			end
            		end
            		if (indicator == 1) && (~failedNodes.contains(chosenNode)) % If there exists a VM with such conditions and the chosen node is not already present in the previous reliability levels
            			isDeployed = 1; % Mark that the new instance is deployed
            			XfviTemp(freeVNF,chosenVM,1) = 1; % Deploy
            			XsfiTemp(sIndex,freeVNF,iota) = 1; % This indicates that the chosen instance is going to be assigned as a backup at level iota
            			vmGene(pos,iota) = chosenVM; % Modify the vm gene
            			nodeGene(pos,iota) = vnMap.get(vmGene(pos,iota)); % Store the physical node
                        usedLinks(pos,iota) = nodeGene(pos,iota);
            			usedInstances(pos,iota) = freeVNF; % Store the instance
            			vmCapacityTemp(chosenVM) = vmCapacityTemp(chosenVM)-1; % Decrease the capacity by 1
            		    vnfCapacityTemp(iota,freeVNF) = vnfCapacityTemp(iota,freeVNF)-1; % Decrease the capacity by 1
                    else % If no such VM is found or the node is used in previous levels
            			%% Step 3 - Choose the closest free VM to deploy this instance
            			minDistance = Inf; % This will store the minimum distance
            			minDistanceVM = 0; % This will store the VM with the minimum distance
            			for vin = 1 : VI % For each instance
            				distance = network(chosenNode,vnMap.get(vin)); % Store the shortest distance from the chosen VM
            				if (distance < minDistance) && (vmCapacityTemp(vin) > 0) && (distance ~= 0) && (~failedNodes.contains(vnMap.get(vin)))
            					minDistanceVM = vin; % Update the new VM
            					minDistance = distance; % Update the new minimum distance
            				end
            			end
            			if minDistanceVM ~= 0 % If we found such a VM
            				isDeployed = 1; % Mark that the new instance is deployed
            				XfviTemp(freeVNF,minDistanceVM,1) = 1; % Deploy
            				XsfiTemp(sIndex,freeVNF,iota) = 1; % This indicates that the chosen instance is going to be assigned as a backup at level iota
            				vmGene(pos,iota) = minDistanceVM; % Modify the vm gene
            				nodeGene(pos,iota) = vnMap.get(vmGene(pos,iota)); % Store the physical node
                            usedLinks(pos,iota) = nodeGene(pos,iota);
            				usedInstances(pos,iota) = freeVNF; % Store the instance
            				vmCapacityTemp(minDistanceVM) = vmCapacityTemp(minDistanceVM)-1; % Decrease the capacity by 1
            			    vnfCapacityTemp(iota,freeVNF) = vnfCapacityTemp(iota,freeVNF)-1; % Decrease the capacity by 1
                        end
            		end
            	end
            	if isDeployed ~= 1 % If step 2 and 3 were not successful i.e. either all corresponding instances are deployed or we couldn't find any closest free VM
            		%% Step 4 - Choose the closest instance to assign
            		minDistance = Inf;
            		minDistanceInstance = 0;
            		minDistanceVM = 0;
            		for fin = fIndex : fIndex+vnfTypes(chain(pos))-1 % For each instance of the same function
                        if vnfCapacityTemp(iota,fin) > 0 % If the VNF instance has more capacity
            			    chosenVM = 0;
            			    for vin = 1 : VI % For each VM
            				    if XfviTemp(fin,vin,1) == 1 % If required VM is spotted
            					    chosenVM = vin;
            					    break;
            				    end
                            end
            			    if (chosenVM ~= 0) && (~failedNodes.contains(vnMap.get(chosenVM)))
	            			    distance = network(vnMap.get(chosenVM),chosenNode);
	            			    if distance < minDistance
                                    if failedNodes.contains(vnMap.get(chosenVM))
                                        failedNodes.contains(vnMap.get(chosenVM))
                                    end
                                    minDistance = distance;
	            				    minDistanceInstance = fin;
	            				    minDistanceVM = chosenVM;
                                end
                            end
                        end
                    end
                    if minDistanceInstance == 0
                        tempVm = 0;
                        for vin = 1 : VI
                            if XfviTemp(fIndex,vin,1) == 1
                                tempVm = vin;
                                break;
                            end
                        end
                        XsfiTemp(sIndex,fIndex,iota) = 1; % Assign
				        vmGene(pos,iota) = tempVm; % Modify the vm gene
            	        nodeGene(pos,iota) = vnMap.get(vmGene(pos,iota)); % Store the physical node
                        usedLinks(pos,iota) = nodeGene(pos,iota);
                        usedInstances(pos,iota) = fIndex; % Store the instance number
                    else
        			    XsfiTemp(sIndex,minDistanceInstance,iota) = 1; % This indicates that the chosen instance is going to be assigned as a backup at level iota
            		    vmGene(pos,iota) = minDistanceVM; % Modify the vm gene
            		    nodeGene(pos,iota) = vnMap.get(vmGene(pos,iota)); % Store the physical node
            		    usedInstances(pos,iota) = minDistanceInstance; % Store the instance
                        usedLinks(pos,iota) = nodeGene(pos,iota);
                        vnfCapacityTemp(iota,minDistanceInstance) = vnfCapacityTemp(iota,minDistanceInstance)-1; % Decrease the capacity by 1
                    end
            	end
            end
        end
        sfcClassData(sIndex).usedLinks = usedLinks;
    	sfcClassData(sIndex).usedInstances = usedInstances;
%     	for e = 1 : chainLength-1 % For each edge in the SFC
%     		startNode = 0;
%     		finalNode = nodeGene(e,iota);
%     		for l = 1 : iota % For each level
%     			startNode = finalNode; % It will start from the previous final node
%     			finalNode = nodeGene(e+1,l); % Next final node will be the node that was the l level node
%     			while startNode ~= finalNode % Till we reach the destination
%     				uNode = startNode; % Current node
%     				vNode = nextHop(startNode,finalNode); % Next hop node
%     				XllviTemp(sIndex,usedInstances(e,iota),usedInstances(e+1,iota),uNode,vNode,iota) = 1;
%     				XllviTemp(sIndex,usedInstances(e,iota),usedInstances(e+1,iota),vNode,uNode,iota) = 1;
%     				startNode = nextHop(startNode,finalNode); % Update the start node
%     			end
%     		end
% 	    end
    end

%     if isFinal == 1
%         cost = zeros(1,r);
%         for iota = 1 : r
%     
% 	        y1 = y1Rel(N, VI, FI, Cvn, Xvn, Cfv, XfviTemp, vmStatus, vnfStatus, isFinal);
% 	        y2 = y2Rel(VI, FI, iota, sIndex, lambda, delta, mu, XfviTemp, XsfiTemp, vnfStatus, sfcClassData, rhoNode, rhoVm, rhoVnf, isFinal);
% 	        y3 = y3Rel(N, FI, L, iota, sIndex, medium, inputNetwork, nextHop, bandwidths, rhoNode, rhoVm, rhoVnf, sfcClassData, isFinal);
%         
% 	        cost(iota) = alpha*y1+(1-alpha)*(y2+y3);
%         end
%     else
        y1 = y1Rel(N, VI, FI, Cvn, Xvn, Cfv, XfviTemp, vmStatus, vnfStatus, isFinal);
        y2 = y2Rel(VI, FI, r, sIndex, lambda, delta, mu, XfviTemp, XsfiTemp, vnfStatus, sfcClassData, rhoNode, rhoVm, rhoVnf, isFinal);
        y3 = y3Rel(N, FI, L, r, sIndex, medium, inputNetwork, nextHop, bandwidths, rhoNode, rhoVm, rhoVnf, sfcClassData, isFinal);
    
        cost = alpha*y1+(1-alpha)*(y2+y3);
%     end
end