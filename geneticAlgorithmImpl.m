function [optCost, optPlacement] = geneticAlgorithmImpl(N, VI, F, FI, S, L, Cvn, Xvn, Cfv, Xfv, Xsf, lambda, delta, mu, medium, network, bandwidths, nextHop, nodeStatus, vmStatus, vnfTypes, vnfStatus, sfcClassData, vnMap, vnfFreq, vmCoreRequirements, vnfCoreRequirement, nodeCapacity, vmCapacity, vnfCapacity, preSumVnf, iterations, populationSize, sIndex)

	global mutationProbability;
    global mutationCount;
    global randomMutationIterations;

    chainLength = sfcClassData(sIndex).chainLength; % Store the length of the current SFC
   	vmPopulations = zeros(populationSize,chainLength); % A matrix to store the vm populations
   	nodePopulations = zeros(populationSize,chainLength); % A matrix to store the node populations
   	fitnessValues = zeros(1,populationSize); % An array to store the fitness values for each member present in the population
   	bestIndex = 1; % Stores the best fitness index
   	worstIndex = 1; % Stores the worst fitness index
   	secondWorstIndex = 1; % Stores the second worst fitness index
   	bestFitnessValue = 0; % Stores the best fitness value
   	worstFitnessValue = 0; % Stores the worst fitness value
   	secondWorstFitnessValue = 0; % Stores the second worst fitness value
    C = 4; % Total number of children to be generated

   	% Fill random combinations in the population matrix, find out the initial vmPopulations, their fitness values, the best and the worst candidates
   	for p = 1 : populationSize % For each member
   		vmPopulations(p,:) = randperm(VI,chainLength); % Generate a random permutation of the VMs
   		for in = 1 : chainLength % For each position
   			nodePopulations(p,in) = vnMap.get(vmPopulations(p,in)); % Store the corresponding physical node
        end
   		fitnessValues(p) = calculateFitnessValue(N, VI, F, FI, S, L, Cvn, Xvn, Cfv, Xfv, Xsf, lambda, delta, mu, medium, network, bandwidths, nextHop, nodeStatus, vmStatus, vnfTypes, vnfStatus, sfcClassData, vnMap, vnfFreq, vmCoreRequirements, vnfCoreRequirement, nodeCapacity, vmCapacity, vnfCapacity, preSumVnf, iterations, populationSize, sIndex, vmPopulations(p,:), nodePopulations(p,:)); % Find out the fitness value and store it
   		if (p > 1) % If we have more than one fitness value
   			if (fitnessValues(p) < fitnessValues(bestIndex)) % If the newly calculated fitness value is less than the best fitness value
   				bestIndex = p; % Update the best fitness index
   			end
   			if (fitnessValues(p) > fitnessValues(worstIndex)) % If the newly calculated fitness value is greater than the worst fitness value
   				secondWorstIndex = worstIndex; % Store the current worst index in the second worst index
   				worstIndex = p; % Update the worst index
   			elseif (fitnessValues(p) > fitnessValues(secondWorstIndex)) % If the newly calculated fitness value is greater than the second worst fitness value
   				secondWorstIndex = p; % Update the second worst index
   			end
   		end
    end

    % sfcClassData(sIndex).chain
    % 
    % vmPopulations
    % nodePopulations
    % fitnessValues
    % 
    % vmPopulations(bestIndex,:)
    % vmPopulations(worstIndex,:)
    % vmPopulations(secondWorstIndex,:)
    % 
    % nodePopulations(bestIndex,:)
    % nodePopulations(worstIndex,:)
    % nodePopulations(secondWorstIndex,:)
    % 
    % fitnessValues(bestIndex)
    % fitnessValues(worstIndex)
    % fitnessValues(secondWorstIndex)

    
   	% GA steps
   	for it = 1 : iterations % For each iteration
   		vmParent1 = vmPopulations(worstIndex); % 1st member for crossover
   		vmParent2 = vmPopulations(secondWorstIndex); % 2nd member for crossover

   		% Crossover
   		[vmChildren] = crossover(vmParent1, vmParent2, chainLength, C); % Perform crossover operation

   		% Mutation
   		mutationCount = mutationCount+1; % Increment the mutation count
   		if (randomMutationIterations.contains(mutationCount)) % If the current iteration is present in the set
   			% Perform mutation
            mutationIndices = randi(chainLength,1,C); % Generate random indices for each child
            newMutationValues = randi(VI,1,C); % Generate new values to replace
            for cin = 1 : C % For each child
                vmChildren(cin,mutationIndices(cin)) = newMutationValues(cin); % Store the new value at the generated index
            end
        end

        nodeChildren = zeros(C,chainLength);
        
        for cin = 1 : C % For each VM child
            for in = 1 : chainLength % For each position
                nodeChildren(cin,in) = vnMap.get(vmChildren(cin,in)); % Store the corresponding physical node
            end
        end

        childrenFitnessValues = zeros(1,C);
        for cin = 1 : C % For each child
            childrenFitnessValues = calculateFitnessValue(N, VI, F, FI, S, L, Cvn, Xvn, Cfv, Xfv, Xsf, lambda, delta, mu, medium, network, bandwidths, nextHop, nodeStatus, vmStatus, vnfTypes, vnfStatus, sfcClassData, vnMap, vnfFreq, vmCoreRequirements, vnfCoreRequirement, nodeCapacity, vmCapacity, vnfCapacity, preSumVnf, iterations, populationSize, sIndex, vmChildren(cin), nodeChildren(cin)); % Find out the fitness value and store it
        end

        [optimalIndex1, optimalIndex2] = getBestTwoChildren(childrenFitnessValues);

   		% Check for uniqueness of the child genes
   		indicator = 0;
   		isWorstUpdated = 0;
   		for in = 1 : chainLength
   			if vmPopulations(worstIndex,in) ~= vmChildren(optimalIndex1,in)
   				indicator = 1;
   				break;
   			end
   		end
		if indicator == 1 % If the child does not exist in the population
			vmPopulations(worstIndex,:) = vmChildren(optimalIndex1,:);
            nodePopulations(worstIndex,:) = nodeChildren(optimalIndex1,:);
			fitnessValues(worstIndex) = childrenFitnessValues(optimalIndex1);
			isWorstUpdated = 1; % Mark worst as updated
		end
		indicator = 0;
		for in = 1 : chainLength
			if (isWorstUpdated == 1 && vmPopulations(secondWorstIndex,in) ~= vmChildren(optimalIndex2,in)) || (isWorstUpdated == 0 && vmPopulations(worstIndex,in) ~= vmChildren(optimalIndex2,in))
				indicator = 1;
				break;
			end
		end
		if indicator == 1 % If the child does not exist in the population
			if isWorstUpdated == 1 % If the worst value is already updated
				vmPopulations(secondWorstIndex,:) = vmChildren(optimalIndex2,:);
				nodePopulations(secondWorstIndex,:) = nodeChildren(optimalIndex2,:);
				fitnessValues(secondWorstIndex) = childrenFitnessValues(optimalIndex2);
			else
				vmPopulations(worstIndex,:) = vmChildren(optimalIndex2,:);
				nodePopulations(worstIndex,:) = nodeChildren(optimalIndex2,:);
				fitnessValues(worstIndex) = childrenFitnessValues(optimalIndex2);
			end
		end

   		% Find out the best fitness value and worst fitness value again
   		if (fitnessValues(worstIndex) < fitnessValues(bestIndex)) % If the newly calculated fitness value is less than the best fitness value
			bestIndex = worstIndex; % Update the best fitness index
		end
		if (fitnessValues(secondWorstIndex) < fitnessValues(bestIndex))
			bestIndex = secondWorstIndex; % Update the best fitness index
		end
		worstIndex = 1;
		secondWorstIndex = 1;
		for p = 2 : populationSize
			if (fitnessValues(p) > fitnessValues(worstIndex)) % If the newly calculated fitness value is greater than the worst fitness value
				secondWorstIndex = worstIndex; % Store the current worst index in the second worst index
				worstIndex = p; % Update the worst index
			elseif (fitnessValues(p) > fitnessValues(secondWorstIndex)) % If the newly calculated fitness value is greater than the second worst fitness value
				secondWorstIndex = p; % Update the second worst index
			end
		end
   	end
    
   	optCost = fitnessValues(bestIndex); % Store the best fitness value
   	optPlacement = vmPopulations(bestIndex); % Store the corresponding placement of VMs
end