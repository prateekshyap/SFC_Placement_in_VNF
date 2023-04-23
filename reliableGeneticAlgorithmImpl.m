function [optCost, optNodePlacement, optVMPlacement] = reliableGeneticAlgorithmImpl(N, VI, F, FI, L, alpha, r, Cvn, Xvn, Cfv, Xfvi, Xsfi, Xllvi, lambda, delta, mu, medium, inputNetwork, network, bandwidths, bridgeStatus, nextHop, nodeClassData, vmStatus, vmCapacity, vnfTypes, vnfStatus, vnfCapacity, sfcClassData, vnMap, fvMap, preSumVnf, iterations, populationSize, sIndex, logFileID, onePercent, totalIterations, itCopy, rhoNode, rhoVm, rhoVnf, execType)

	global mutationProbability;
    global mutationCount;
    global randomMutationIterations;

    import java.util.TreeSet;

    chainLength = sfcClassData(sIndex).chainLength; % Store the length of the current SFC
   	vmPopulations = zeros(populationSize,chainLength,r); % A matrix to store the vm populations
   	nodePopulations = zeros(populationSize,chainLength,r); % A matrix to store the node populations
   	fitnessValues = zeros(1,populationSize); % An array to store the fitness values for each member present in the population
   	bestIndex = 1; % Stores the best fitness index
   	worstIndex = 0; % Stores the worst fitness index
   	secondWorstIndex = 0; % Stores the second worst fitness index
   	bestFitnessValue = 0; % Stores the best fitness value
   	worstFitnessValue = 0; % Stores the worst fitness value
   	secondWorstFitnessValue = 0; % Stores the second worst fitness value
    C = 4; % Total number of children to be generated

   	% Fill random combinations in the population matrix, find out the initial vmPopulations, their fitness values, the best and the worst candidates
   	for p = 1 : populationSize % For each member
   		%% Generate population data
   		[nodePopulations(p,:,:), vmPopulations(p,:,:)] = generatePopulation(N, VI, chainLength, r, nodeClassData);
        nodePop = zeros(chainLength,r);
        nodePop(:,:) = nodePopulations(p,:,:);
        vmPop = zeros(chainLength,r);
        vmPop(:,:) = vmPopulations(p,:,:);
   		[fitnessValues(p),nodePopulations(p,:,:),vmPopulations(p,:,:),t1,t2,t3,t4,t5,t6] = calculateReliableFitnessValue(N, VI, F, FI, L, alpha, Cvn, Xvn, Cfv, Xfvi, Xsfi, Xllvi, lambda, delta, mu, medium, inputNetwork, network, bandwidths, bridgeStatus, nextHop, vmStatus, vnfTypes, vnfStatus, sfcClassData, vnMap, vmCapacity, vnfCapacity, preSumVnf, sIndex, nodePop, vmPop, r, nodeClassData, rhoNode, rhoVm, rhoVnf, 0); % Find out the fitness value and store it
   		if p > 1 % If we have more than one fitness value
   			if fitnessValues(p) < fitnessValues(bestIndex) % If the newly calculated fitness value is less than the best fitness value
   				bestIndex = p; % Update the best fitness index
   			end
   		end
		if worstIndex == 0 || fitnessValues(p) > fitnessValues(worstIndex) % If the newly calculated fitness value is greater than the worst fitness value
			secondWorstIndex = worstIndex; % Store the current worst index in the second worst index
			worstIndex = p; % Update the worst index
		elseif secondWorstIndex == 0 || fitnessValues(p) > fitnessValues(secondWorstIndex) % If the newly calculated fitness value is greater than the second worst fitness value
			secondWorstIndex = p; % Update the second worst index
		end
    end

    worstConstantCount = 0;
    previousWorstFitnessValue = fitnessValues(worstIndex);
    
   	%% GA steps
   	for it = 1 : iterations % For each iteration
   		nodeParent1 = zeros(chainLength,r);
        nodeParent1(:,:) = nodePopulations(worstIndex,:,:); % 1st member for crossover
        nodeParent2 = zeros(chainLength,r);
        nodeParent2(:,:) = nodePopulations(secondWorstIndex,:,:); % 2nd member for crossover
   		vmParent1 = zeros(chainLength,r);
        vmParent1(:,:) = vmPopulations(worstIndex,:,:); % 1st member for crossover
        vmParent2 = zeros(chainLength,r);
        vmParent2(:,:) = vmPopulations(secondWorstIndex,:,:); % 2nd member for crossover

   		% Hybrid Offspring Formation
   		[nodeChildren, vmChildren] = crossoverRel(nodeParent1, nodeParent2, vmParent1, vmParent2, vnMap, chainLength, C, VI, r, execType); % Perform crossover operation

   		% Finding out fitness values
        childrenFitnessValues = zeros(1,C);
        for cin = 1 : C % For each child
            nodePop = zeros(chainLength,r);
            nodePop(:,:) = nodeChildren(cin,:,:);
            vmPop = zeros(chainLength,r);
            vmPop(:,:) = vmChildren(cin,:,:);
            [childrenFitnessValues(cin),nodeChildren(cin,:,:),vmChildren(cin,:,:),t1,t2,t3,t4,t5,t6] = calculateReliableFitnessValue(N, VI, F, FI, L, alpha, Cvn, Xvn, Cfv, Xfvi, Xsfi, Xllvi, lambda, delta, mu, medium, inputNetwork, network, bandwidths, bridgeStatus, nextHop, vmStatus, vnfTypes, vnfStatus, sfcClassData, vnMap, vmCapacity, vnfCapacity, preSumVnf, sIndex, nodePop, vmPop, r, nodeClassData, rhoNode, rhoVm, rhoVnf, 0); % Find out the fitness value and store it
        end
        %{
        if execType == 1
        % Uncomment this block when you're executing this algorithm with uniform crossover
        childrenFitnessValues(3) = Inf;
        childrenFitnessValues(4) = Inf;
		%}
        end
		%}
        [childrenFitnessValues, nodeChildren, vmChildren] = getSortedChildrenRel(childrenFitnessValues, nodeChildren, vmChildren, C, chainLength, r); % Sort the children in ascending order of their fitness values

   		% Check for uniqueness of the child genes
   		uniqueChildren = ones(1,C); % By default each child is unique
   		%{
   		if execType == 1
        % Uncomment this block when you're executing this algorithm with uniform crossover
        uniqueChildren(3) = 0;
        uniqueChildren(4) = 0;
   		%}
        end
   		indicator = 0;
   		for cin = 1 : C % For each child
	   		for p = 1 : populationSize % For each member in population matrix
	   			indicator = 0; % Reset the indicator
	   			for iota = 1 : r % For each reliability level
		   			for in = 1 : chainLength % For each VM
		   				if vmPopulations(p,in,iota) ~= vmChildren(cin,in,iota) % If at least one mismatch is found
		   					indicator = 1; % Mark it
		   					break;
		   				end
		   			end
		   		end
	   			if indicator == 0 % If no mismatch is found i.e. the child is already present in the population matrix
	   				uniqueChildren(cin) = 0; % Mark it as non-unique
	   				break;
	   			end
	   		end
        end
   		uniqueIndex1 = 1;
   		uniqueIndex2 = 1;
   		while uniqueIndex1 <= 4 && uniqueChildren(uniqueIndex1) == 0 % Until we find an unique child
   			uniqueIndex1 = uniqueIndex1+1; % Increment the index
   			uniqueIndex2 = uniqueIndex2+1; % Increment the index
   		end
   		uniqueIndex2 = uniqueIndex2+1; % Increment the second index
   		while uniqueIndex2 <= 4 && uniqueChildren(uniqueIndex2) == 0 % Until we find the second unique child
   			uniqueIndex2 = uniqueIndex2+1; % Increment the index
        end
        % The logic here is, if we want to replace both the parents, then the child with higher fitness value must be
        % smaller than the worst parent and the child with the lower fitness value must be smaller than the second
        % worst parent
        % Trivially the best child would be anyways better than the worst parent, so we shall take the other case,
        % and if it satisfies then we shall replace both the parents
        % If this does not satisfy, then we shall check for the worst parent and the best child
   		if uniqueIndex2 <= 4 && fitnessValues(worstIndex) > childrenFitnessValues(uniqueIndex2) && uniqueIndex1 <= 4 && fitnessValues(worstIndex) > childrenFitnessValues(uniqueIndex1)
   			nodePopulations(worstIndex,:,:) = nodeChildren(uniqueIndex2,:,:);
   			vmPopulations(worstIndex,:,:) = vmChildren(uniqueIndex2,:,:);
			fitnessValues(worstIndex) = childrenFitnessValues(uniqueIndex2);
			nodePopulations(secondWorstIndex,:,:) = nodeChildren(uniqueIndex1,:,:);
			vmPopulations(secondWorstIndex,:,:) = vmChildren(uniqueIndex1,:,:);
			fitnessValues(secondWorstIndex) = childrenFitnessValues(uniqueIndex1);
		elseif uniqueIndex1 <= 4 && fitnessValues(worstIndex) > childrenFitnessValues(uniqueIndex1)
			nodePopulations(worstIndex,:,:) = nodeChildren(uniqueIndex1,:,:);
			vmPopulations(worstIndex,:,:) = vmChildren(uniqueIndex1,:,:);
			fitnessValues(worstIndex) = childrenFitnessValues(uniqueIndex1);
		end
		
   		% Find out the best fitness value and worst fitness value again
   		if (fitnessValues(worstIndex) < fitnessValues(bestIndex)) % If the newly calculated fitness value is less than the best fitness value
			bestIndex = worstIndex; % Update the best fitness index
		end
		if (fitnessValues(secondWorstIndex) < fitnessValues(bestIndex))
			bestIndex = secondWorstIndex; % Update the best fitness index
		end
		worstIndex = 0;
		secondWorstIndex = 0;
		for p = 1 : populationSize
			if worstIndex == 0 || fitnessValues(p) > fitnessValues(worstIndex) % If the newly calculated fitness value is greater than the worst fitness value
				secondWorstIndex = worstIndex; % Store the current worst index in the second worst index
				worstIndex = p; % Update the worst index
			elseif secondWorstIndex == 0 || fitnessValues(p) > fitnessValues(secondWorstIndex) % If the newly calculated fitness value is greater than the second worst fitness value
				secondWorstIndex = p; % Update the second worst index
			end
        end
        
        if (fitnessValues(worstIndex) == previousWorstFitnessValue) % If the current worst fitness value is same as the previous
        	worstConstantCount = worstConstantCount+1; % Increment the count
        	if worstConstantCount >= 10 % If the count reaches 10 i.e. the worst value has not changed for the last 10 iterations, perform mutagenesis
        		% Mutagenesis
        		bestGene = vmPopulations(bestIndex); % Get the best chromosome from the population
        		mutagenesisSize = ceil(chainLength*mutationProbability/100); % Get the number of positions to be inherited
        		indices = randperm(chainLength,mutagenesisSize); % Generate a random permutation of indices
        		nodeMutaGene1 = zeros(chainLength,r);
        		nodeMutaGene1(:,:) = nodePopulations(worstIndex,:,:); % Copy the worst chromosome
        		nodeMutaGene2 = zeros(chainLength,r);
        		nodeMutaGene2(:,:) = nodePopulations(secondWorstIndex,:,:); % Copy the second one
        		vmMutaGene1 = zeros(chainLength,r);
        		vmMutaGene1(:,:) = vmPopulations(worstIndex,:,:); % Copy the worst chromosome
        		vmMutaGene2 = zeros(chainLength,r);
        		vmMutaGene2(:,:) = vmPopulations(secondWorstIndex,:,:); % Copy the second one
        		for ind = 1 : mutagenesisSize % For each position
        			nodeMutaGene1(indices(ind),:) = nodePopulations(bestIndex,indices(ind),:);
        			nodeMutaGene2(indices(ind),:) = nodePopulations(bestIndex,indices(ind),:);
        			vmMutaGene1(indices(ind),:) = vmPopulations(bestIndex,indices(ind),:); % Copy from the best child
        			vmMutaGene2(indices(ind),:) = vmPopulations(bestIndex,indices(ind),:); % Copy from the best child
        		end
        		% Find out the fitness values
        		fitnessValue1 = calculateReliableFitnessValue(N, VI, F, FI, L, alpha, Cvn, Xvn, Cfv, Xfvi, Xsfi, Xllvi, lambda, delta, mu, medium, inputNetwork, network, bandwidths, bridgeStatus, nextHop, vmStatus, vnfTypes, vnfStatus, sfcClassData, vnMap, vmCapacity, vnfCapacity, preSumVnf, sIndex, nodeMutaGene1, vmMutaGene1, r, nodeClassData, rhoNode, rhoVm, rhoVnf, 0); % Find out the fitness value and store it
                fitnessValue2 = calculateReliableFitnessValue(N, VI, F, FI, L, alpha, Cvn, Xvn, Cfv, Xfvi, Xsfi, Xllvi, lambda, delta, mu, medium, inputNetwork, network, bandwidths, bridgeStatus, nextHop, vmStatus, vnfTypes, vnfStatus, sfcClassData, vnMap, vmCapacity, vnfCapacity, preSumVnf, sIndex, nodeMutaGene2, vmMutaGene2, r, nodeClassData, rhoNode, rhoVm, rhoVnf, 0); % Find out the fitness value and store it
        		% Update the worst chromosomes if the fitness values are improved after mutagenesis
        		if fitnessValue1 < fitnessValues(worstIndex)
        			nodePopulations(worstIndex,:,:) = nodeMutaGene1;
        			vmPopulations(worstIndex,:,:) = vmMutaGene1;
        			fitnessValues(worstIndex) = fitnessValue1;
        		end
        		if fitnessValue2 < fitnessValues(secondWorstIndex)
        			nodePopulations(secondWorstIndex,:,:) = nodeMutaGene2;
        			vmPopulations(secondWorstIndex,:,:) = vmMutaGene2;
        			fitnessValues(secondWorstIndex) = fitnessValue2;
        		end
        	end
        else
        	previousWorstFitnessValue = fitnessValues(worstIndex);
        	worstConstantCount = 0;
        end
		
        % Find out the best fitness value and worst fitness value again
   		if (fitnessValues(worstIndex) < fitnessValues(bestIndex)) % If the newly calculated fitness value is less than the best fitness value
			bestIndex = worstIndex; % Update the best fitness index
		end
		if (fitnessValues(secondWorstIndex) < fitnessValues(bestIndex))
			bestIndex = secondWorstIndex; % Update the best fitness index
		end
		worstIndex = 0;
		secondWorstIndex = 0;
		for p = 1 : populationSize
			if worstIndex == 0 || fitnessValues(p) > fitnessValues(worstIndex) % If the newly calculated fitness value is greater than the worst fitness value
				secondWorstIndex = worstIndex; % Store the current worst index in the second worst index
				worstIndex = p; % Update the worst index
			elseif secondWorstIndex == 0 || fitnessValues(p) > fitnessValues(secondWorstIndex) % If the newly calculated fitness value is greater than the second worst fitness value
				secondWorstIndex = p; % Update the second worst index
			end
        end

        % if (fitnessValues(worstIndex) == previousWorstFitnessValue)
        % 	if worstConstantCount >= 30
        % 		break;
        % 	end
        % else
        % 	previousWorstFitnessValue = fitnessValues(worstIndex);
        % 	worstConstantCount = 0;
        % end

		if mod(it,onePercent) == 0
			percent = ((sIndex-1)*itCopy+it)/onePercent;
			for back = 1 : 104
				fprintf('\b');
			end
			for fwd = 1 : percent
				fprintf('|');
			end
			for fwd = percent+1 : 100
				fprintf(' ');
			end
			fprintf(']');
			if percent < 10
				fprintf('  %d',percent);
			elseif percent < 100
				fprintf(' %d',percent);
			else
				fprintf('%d\n',percent);
			end
        end
   	end
    
   	optCost = fitnessValues(bestIndex); % Store the best fitness value
    optVMPlacement = zeros(chainLength,r);
   	optVMPlacement(:,:) = vmPopulations(bestIndex,:,:); % Store the corresponding placement of VMs
    optNodePlacement = zeros(chainLength,r);
   	optNodePlacement(:,:) = nodePopulations(bestIndex,:,:); % Store the corresponding placement of nodes
end