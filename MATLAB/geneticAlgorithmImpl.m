% function [optCost, optPlacement] = geneticAlgorithmImpl(N, VI, F, FI, L, Cvn, Xvn, Cfv, Xfv, Xsf, lambda, delta, mu, medium, network, bandwidths, nextHop, vmStatus, vmCapacity, vnfTypes, vnfStatus, vnfCapacity, sfcClassData, vnMap, fvMap, preSumVnf, iterations, populationSize, sIndex, logFileID, onePercent, totalIterations)
function [optCost, optPlacement] = geneticAlgorithmImpl(N, VI, F, FI, L, Cvn, Xvn, Cfv, Xfv, Xsf, lambda, delta, mu, medium, network, bandwidths, nextHop, vmStatus, vmCapacity, vnfTypes, vnfStatus, vnfCapacity, sfcClassData, vnMap, fvMap, preSumVnf, iterations, populationSize, sIndex, onePercent, totalIterations, crossoverType)

	global mutationProbability;
    global mutationCount;
    global randomMutationIterations;

    import java.util.TreeSet;

    chainLength = sfcClassData(sIndex).chainLength; % Store the length of the current SFC
   	vmPopulations = zeros(populationSize,chainLength); % A matrix to store the vm populations
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
   		vmPopulations(p,:) = randperm(VI,chainLength); % Generate a random permutation of the VMs
   		[fitnessValues(p),vmPopulations(p,:),t1,t2,t3,t4,t5] = calculateFitnessValue(N, VI, F, FI, L, Cvn, Xvn, Cfv, Xfv, Xsf, lambda, delta, mu, medium, network, bandwidths, nextHop, vmStatus, vnfTypes, vnfStatus, sfcClassData, vnMap, vmCapacity, vnfCapacity, preSumVnf, sIndex, vmPopulations(p,:)); % Find out the fitness value and store it
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

   	% GA steps
   	for it = 1 : iterations % For each iteration
        vmParent1 = vmPopulations(worstIndex,:); % 1st member for crossover
   		vmParent2 = vmPopulations(secondWorstIndex,:); % 2nd member for crossover

   		% Hybrid Offspring Formation
   		[vmChildren] = crossover(vmParent1, vmParent2, chainLength, C, VI, crossoverType); % Perform crossover operation
		
        childrenFitnessValues = zeros(1,C);
        for cin = 1 : C % For each child
            [childrenFitnessValues(cin),vmChildren(cin,:),t1,t2,t3,t4,t5] = calculateFitnessValue(N, VI, F, FI, L, Cvn, Xvn, Cfv, Xfv, Xsf, lambda, delta, mu, medium, network, bandwidths, nextHop, vmStatus, vnfTypes, vnfStatus, sfcClassData, vnMap, vmCapacity, vnfCapacity, preSumVnf, sIndex, vmChildren(cin,:)); % Find out the fitness value and store it
        end

<<<<<<< HEAD
		fprintf(logFileID,'%s\n','Children ');
	    for i = 1 : C
			for j = 1 : chainLength
				fprintf(logFileID,'%d\t',vmChildren(i,j));
			end
			fprintf(logFileID,'\n');
		end
		fprintf(logFileID,'\n\n');

        % childrenFitnessValues
		fprintf(logFileID,'%s\n','Children Fitness Values ');
	    for i = 1 : C
			fprintf(logFileID,'%d\t',childrenFitnessValues(i));
		end
		fprintf(logFileID,'\n\n');

        [childrenFitnessValues, vmChildren] = getSortedChildren(childrenFitnessValues, vmChildren, C, chainLength); % Sort the children in ascending order of their fitness values
        fprintf(logFileID,'%s\n\n','After sorting ');
	    fprintf(logFileID,'%s\n','Children ');
	    for i = 1 : C
			for j = 1 : chainLength
				fprintf(logFileID,'%d\t',vmChildren(i,j));
			end
			fprintf(logFileID,'\n');
		end
		fprintf(logFileID,'\n\n');
		fprintf(logFileID,'%s\n','Children Fitness Values ');
	    for i = 1 : C
			fprintf(logFileID,'%d\t',childrenFitnessValues(i));
		end
		fprintf(logFileID,'\n\n');

=======
        [childrenFitnessValues, vmChildren] = getSortedChildren(childrenFitnessValues, vmChildren, C, chainLength);
        
>>>>>>> main
   		% Check for uniqueness of the child genes
   		uniqueChildren = ones(1,C); % By default each child is unique
   		indicator = 0;
   		for cin = 1 : C % For each child
	   		for p = 1 : populationSize % For each member in population matrix
	   			indicator = 0; % Reset the indicator
	   			for in = 1 : chainLength % For each VM
	   				if vmPopulations(p,in) ~= vmChildren(cin,in) % If at least one mismatch is found
	   					indicator = 1; % Mark it
	   					break;
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
   			vmPopulations(worstIndex,:) = vmChildren(uniqueIndex2,:);
			fitnessValues(worstIndex) = childrenFitnessValues(uniqueIndex2);
			vmPopulations(secondWorstIndex,:) = vmChildren(uniqueIndex1,:);
			fitnessValues(secondWorstIndex) = childrenFitnessValues(uniqueIndex1);
		elseif uniqueIndex1 <= 4 && fitnessValues(worstIndex) > childrenFitnessValues(uniqueIndex1)
			vmPopulations(worstIndex,:) = vmChildren(uniqueIndex1,:);
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
        %{
        if (fitnessValues(worstIndex) == previousWorstFitnessValue) % If the current worst fitness value is same as the previous
        	worstConstantCount = worstConstantCount+1; % Increment the count
        	if worstConstantCount >= 10 % If the count reaches 10 i.e. the worst value has not changed for the last 10 iterations, perform mutagenesis
        		% Mutagenesis
        		bestGene = vmPopulations(bestIndex); % Get the best chromosome from the population
        		mutagenesisSize = ceil(chainLength*mutationProbability/100); % Get the number of positions to be inherited
        		indices = randperm(chainLength,mutagenesisSize); % Generate a random permutation of indices
        		mutaGene1 = vmPopulations(worstIndex,:); % Copy the worst chromosome
        		mutaGene2 = vmPopulations(secondWorstIndex,:); % Copy the second one
        		for ind = 1 : mutagenesisSize % For each position
        			mutaGene1(indices(ind)) = vmPopulations(bestIndex,indices(ind)); % Copy from the best child
        			mutaGene2(indices(ind)) = vmPopulations(bestIndex,indices(ind)); % Copy from the best child
        		end
        		% Find out the fitness values
        		fitnessValue1 = calculateFitnessValue(N, VI, F, FI, L, Cvn, Xvn, Cfv, Xfv, Xsf, lambda, delta, mu, medium, network, bandwidths, nextHop, vmStatus, vnfTypes, vnfStatus, sfcClassData, vnMap, vmCapacity, vnfCapacity, preSumVnf, sIndex, mutaGene1); % Find out the fitness value and store it
        		fitnessValue2 = calculateFitnessValue(N, VI, F, FI, L, Cvn, Xvn, Cfv, Xfv, Xsf, lambda, delta, mu, medium, network, bandwidths, nextHop, vmStatus, vnfTypes, vnfStatus, sfcClassData, vnMap, vmCapacity, vnfCapacity, preSumVnf, sIndex, mutaGene2); % Find out the fitness value and store it
        		% Update the worst chromosomes if the fitness values are improved after mutagenesis
        		if fitnessValue1 < fitnessValues(worstIndex)
        			vmPopulations(worstIndex,:) = mutaGene1;
        			fitnessValues(worstIndex) = fitnessValue1;
        			% worstConstantCount = 0; % Reset the count
        		end
        		if fitnessValue2 < fitnessValues(secondWorstIndex)
        			vmPopulations(secondWorstIndex,:) = mutaGene2;
        			fitnessValues(secondWorstIndex) = fitnessValue2;
        			% worstConstantCount = 0; % Reset the count
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

<<<<<<< HEAD
        % if (fitnessValues(worstIndex) == previousWorstFitnessValue)
        % 	if worstConstantCount >= 30
        % 		break;
        % 	end
        % else
        % 	previousWorstFitnessValue = fitnessValues(worstIndex);
        % 	worstConstantCount = 0;
        % end
		%}
		fprintf(logFileID,'\n\n');
        % sfcClassData(sIndex).chain
	    fprintf(logFileID,'%s\n','chain ');
	    for i = 1 : sfcClassData(sIndex).chainLength
			fprintf(logFileID,'%d\t',sfcClassData(sIndex).chain(i));
		end
		fprintf(logFileID,'\n\n');

	    % vmPopulations
	    fprintf(logFileID,'%s\n','Population ');
	    for i = 1 : populationSize
			for j = 1 : chainLength
				fprintf(logFileID,'%d\t',vmPopulations(i,j));
			end
			fprintf(logFileID,'\n');
		end
		fprintf(logFileID,'\n\n');
	    % fitnessValues
		fprintf(logFileID,'%s\n','Fitness Values ');
	    for i = 1 : populationSize
			fprintf(logFileID,'%d\t',fitnessValues(i));
		end
		fprintf(logFileID,'\n\n');

	    % vmPopulations(bestIndex,:)
		fprintf(logFileID,'%s\n','Best Gene ');
	    for i = 1 : chainLength
			fprintf(logFileID,'%d\t',vmPopulations(bestIndex,i));
		end
		fprintf(logFileID,'\n\n');
	    % vmPopulations(worstIndex,:)
		fprintf(logFileID,'%s\n','Worst Gene ');
	    for i = 1 : chainLength
			fprintf(logFileID,'%d\t',vmPopulations(worstIndex,i));
		end
		fprintf(logFileID,'\n\n');
	    % vmPopulations(secondWorstIndex,:)
		fprintf(logFileID,'%s\n','Second Worst Gene ');
	    for i = 1 : chainLength
			fprintf(logFileID,'%d\t',vmPopulations(secondWorstIndex,i));
		end
		fprintf(logFileID,'\n\n');

	    % fitnessValues(bestIndex)
		fprintf(logFileID,'%s\n','Best Fitness Value ');
		fprintf(logFileID,'%f\n\n',fitnessValues(bestIndex));
	    % fitnessValues(worstIndex)
		fprintf(logFileID,'%s\n','Worst Fitness Value ');
		fprintf(logFileID,'%f\n\n',fitnessValues(worstIndex));
	    % fitnessValues(secondWorstIndex)
		fprintf(logFileID,'%s\n','Second Worst Fitness Value ');
		fprintf(logFileID,'%f\n\n',fitnessValues(secondWorstIndex));

=======
>>>>>>> main
		if mod(it,onePercent) == 0
			percent = ((sIndex-1)*iterations+it)/onePercent;
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
   	optPlacement = vmPopulations(bestIndex,:); % Store the corresponding placement of VMs
end