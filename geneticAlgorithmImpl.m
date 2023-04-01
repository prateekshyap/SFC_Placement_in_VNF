function [optCost, optPlacement] = geneticAlgorithmImpl(N, VI, F, FI, L, Cvn, Xvn, Cfv, Xfv, Xsf, lambda, delta, mu, medium, network, bandwidths, nextHop, vmStatus, vnfTypes, vnfStatus, sfcClassData, vnMap, vnfCapacity, preSumVnf, iterations, populationSize, sIndex, logFileID)

	global mutationProbability;
    global mutationCount;
    global randomMutationIterations;

    import java.util.TreeSet;

    chainLength = sfcClassData(sIndex).chainLength; % Store the length of the current SFC
   	vmPopulations = zeros(populationSize,chainLength); % A matrix to store the vm populations
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
   		% for in = 1 : chainLength % For each position
   		% 	nodePopulations(p,in) = vnMap.get(vmPopulations(p,in)); % Store the corresponding physical node
        % end
   		fitnessValues(p) = calculateFitnessValue(N, VI, F, FI, L, Cvn, Xvn, Cfv, Xfv, Xsf, lambda, delta, mu, medium, network, bandwidths, nextHop, vmStatus, vnfTypes, vnfStatus, sfcClassData, vnMap, vnfCapacity, preSumVnf, sIndex, vmPopulations(p,:)); % Find out the fitness value and store it
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

    sfcClassData(sIndex).chain
    fprintf(logFileID,'%s\n','chain ');
    for i = 1 : sfcClassData(sIndex).chainLength
		fprintf(logFileID,'%d\t',sfcClassData(sIndex).chain(i));
	end
	fprintf(logFileID,'\n\n');

    vmPopulations
    fprintf(logFileID,'%s\n','Population ');
    for i = 1 : populationSize
		for j = 1 : chainLength
			fprintf(logFileID,'%d\t',vmPopulations(i,j));
		end
		fprintf(logFileID,'\n');
	end
	fprintf(logFileID,'\n\n');
    fitnessValues
	fprintf(logFileID,'%s\n','Fitness Values ');
    for i = 1 : populationSize
		fprintf(logFileID,'%d\t',fitnessValues(i));
	end
	fprintf(logFileID,'\n\n');

    vmPopulations(bestIndex,:)
	fprintf(logFileID,'%s\n','Best Gene ');
    for i = 1 : chainLength
		fprintf(logFileID,'%d\t',vmPopulations(bestIndex,i));
	end
	fprintf(logFileID,'\n\n');
    vmPopulations(worstIndex,:)
	fprintf(logFileID,'%s\n','Worst Gene ');
    for i = 1 : chainLength
		fprintf(logFileID,'%d\t',vmPopulations(worstIndex,i));
	end
	fprintf(logFileID,'\n\n');
    vmPopulations(secondWorstIndex,:)
	fprintf(logFileID,'%s\n','Second Worst Gene ');
    for i = 1 : chainLength
		fprintf(logFileID,'%d\t',vmPopulations(secondWorstIndex,i));
	end
	fprintf(logFileID,'\n\n');

    fitnessValues(bestIndex)
	fprintf(logFileID,'%s\n','Best Fitness Value ');
	fprintf(logFileID,'%f\n\n',fitnessValues(bestIndex));
    fitnessValues(worstIndex)
	fprintf(logFileID,'%s\n','Worst Fitness Value ');
	fprintf(logFileID,'%f\n\n',fitnessValues(worstIndex));
    fitnessValues(secondWorstIndex)
	fprintf(logFileID,'%s\n','Second Worst Fitness Value ');
	fprintf(logFileID,'%f\n\n',fitnessValues(secondWorstIndex));

    
   	% GA steps
   	for it = 1 : iterations % For each iteration
        fprintf('Iteration number: %d',it);
        fprintf(logFileID,'%s%d\n\n','Iteration number: ',it);
   		vmParent1 = vmPopulations(worstIndex,:) % 1st member for crossover
   		vmParent2 = vmPopulations(secondWorstIndex,:) % 2nd member for crossover
   		fprintf(logFileID,'%s\n','Parent 1 ');
	    for i = 1 : chainLength
			fprintf(logFileID,'%d\t',vmParent1(i));
		end
		fprintf(logFileID,'\n\n');
		fprintf(logFileID,'%s\n','Parent 2 ');
	    for i = 1 : chainLength
			fprintf(logFileID,'%d\t',vmParent2(i));
		end
		fprintf(logFileID,'\n\n');

   		% Crossover
   		[vmChildren] = crossover(vmParent1, vmParent2, chainLength, C) % Perform crossover operation
		fprintf(logFileID,'%s\n','Children ');
	    for i = 1 : C
			for j = 1 : chainLength
				fprintf(logFileID,'%d\t',vmChildren(i,j));
			end
			fprintf(logFileID,'\n');
		end
		fprintf(logFileID,'\n\n');
   		% Mutation
   		mutationCount = mutationCount+1; % Increment the mutation count
   		if (randomMutationIterations.contains(mutationCount)) % If the current iteration is present in the set
   			% Perform mutation
            fprintf('Mutation being performed');
            mutationIndices = randi(chainLength,1,C); % Generate random indices for each child
            newMutationValues = zeros(C,chainLength+1); % This will store length+1 new values to ensure that we have at least one value that is currently not present in the child gene
            for cin = 1 : C % For each child
                newMutationValues(cin,:) = randperm(VI,chainLength+1); % Generate a random permutation of length+1
            end
            for cin = 1 : C % For each child
                geneValues = TreeSet(); % Initialize
                for in = 1 : chainLength % For each value
                    geneValues.add(vmChildren(cin,in)); % Add it to the treeset
                end
                for in = 1 : chainLength+1 % For each value present in the mutation permutation
                    if ~geneValues.contains(newMutationValues(cin,in)) % If the current mutation value is not present in the gene
                        vmChildren(cin,mutationIndices(cin)) = newMutationValues(cin,in); % Store the new value at the generated index
                        break;
                    end
                end
            end
            vmChildren
			fprintf(logFileID,'%s\n','Children ');
		    for i = 1 : C
				for j = 1 : chainLength
					fprintf(logFileID,'%d\t',vmChildren(i,j));
				end
				fprintf(logFileID,'\n');
			end
			fprintf(logFileID,'\n\n');
        end

        childrenFitnessValues = zeros(1,C);
        for cin = 1 : C % For each child
            childrenFitnessValues(cin) = calculateFitnessValue(N, VI, F, FI, L, Cvn, Xvn, Cfv, Xfv, Xsf, lambda, delta, mu, medium, network, bandwidths, nextHop, vmStatus, vnfTypes, vnfStatus, sfcClassData, vnMap, vnfCapacity, preSumVnf, sIndex, vmChildren(cin,:)); % Find out the fitness value and store it
        end

        childrenFitnessValues
		fprintf(logFileID,'%s\n','Children Fitness Values ');
	    for i = 1 : C
			fprintf(logFileID,'%d\t',childrenFitnessValues(i));
		end
		fprintf(logFileID,'\n\n');

        [optimalIndex1, optimalIndex2] = getBestTwoChildren(childrenFitnessValues)
        fprintf(logFileID,'%s\n','Optimal Indices ');
	    for i = 1 : C
			fprintf(logFileID,'%d, %d\t',optimalIndex1,optimalIndex2);
		end
		fprintf(logFileID,'\n\n');

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
				fitnessValues(secondWorstIndex) = childrenFitnessValues(optimalIndex2);
			else
				vmPopulations(worstIndex,:) = vmChildren(optimalIndex2,:);
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
		fprintf(logFileID,'\n\n');
        sfcClassData(sIndex).chain
	    fprintf(logFileID,'%s\n','chain ');
	    for i = 1 : sfcClassData(sIndex).chainLength
			fprintf(logFileID,'%d\t',sfcClassData(sIndex).chain(i));
		end
		fprintf(logFileID,'\n\n');

	    vmPopulations
	    fprintf(logFileID,'%s\n','Population ');
	    for i = 1 : populationSize
			for j = 1 : chainLength
				fprintf(logFileID,'%d\t',vmPopulations(i,j));
			end
			fprintf(logFileID,'\n');
		end
		fprintf(logFileID,'\n\n');
	    fitnessValues
		fprintf(logFileID,'%s\n','Fitness Values ');
	    for i = 1 : populationSize
			fprintf(logFileID,'%d\t',fitnessValues(i));
		end
		fprintf(logFileID,'\n\n');

	    vmPopulations(bestIndex,:)
		fprintf(logFileID,'%s\n','Best Gene ');
	    for i = 1 : chainLength
			fprintf(logFileID,'%d\t',vmPopulations(bestIndex,i));
		end
		fprintf(logFileID,'\n\n');
	    vmPopulations(worstIndex,:)
		fprintf(logFileID,'%s\n','Worst Gene ');
	    for i = 1 : chainLength
			fprintf(logFileID,'%d\t',vmPopulations(worstIndex,i));
		end
		fprintf(logFileID,'\n\n');
	    vmPopulations(secondWorstIndex,:)
		fprintf(logFileID,'%s\n','Second Worst Gene ');
	    for i = 1 : chainLength
			fprintf(logFileID,'%d\t',vmPopulations(secondWorstIndex,i));
		end
		fprintf(logFileID,'\n\n');

	    fitnessValues(bestIndex)
		fprintf(logFileID,'%s\n','Best Fitness Value ');
		fprintf(logFileID,'%f\n\n',fitnessValues(bestIndex));
	    fitnessValues(worstIndex)
		fprintf(logFileID,'%s\n','Worst Fitness Value ');
		fprintf(logFileID,'%f\n\n',fitnessValues(worstIndex));
	    fitnessValues(secondWorstIndex)
		fprintf(logFileID,'%s\n','Second Worst Fitness Value ');
		fprintf(logFileID,'%f\n\n',fitnessValues(secondWorstIndex));
   	end
    
   	optCost = fitnessValues(bestIndex); % Store the best fitness value
   	optPlacement = vmPopulations(bestIndex,:); % Store the corresponding placement of VMs
end