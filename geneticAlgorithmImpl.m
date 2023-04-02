function [optCost, optPlacement] = geneticAlgorithmImpl(N, VI, F, FI, L, Cvn, Xvn, Cfv, Xfv, Xsf, lambda, delta, mu, medium, network, bandwidths, nextHop, vmStatus, vmCapacity, vnfTypes, vnfStatus, vnfCapacity, sfcClassData, vnMap, fvMap, preSumVnf, iterations, populationSize, sIndex, logFileID)

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
   		[fitnessValues(p),t1,t2,t3,t4,t5] = calculateFitnessValue(N, VI, F, FI, L, Cvn, Xvn, Cfv, Xfv, Xsf, lambda, delta, mu, medium, network, bandwidths, nextHop, vmStatus, vnfTypes, vnfStatus, sfcClassData, vnMap, vmCapacity, vnfCapacity, preSumVnf, sIndex, vmPopulations(p,:)); % Find out the fitness value and store it
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

    
   	% GA steps
   	for it = 1 : iterations % For each iteration
        fprintf(logFileID,'%s%d%s\n\n','-------------------------------------------Iteration number: ',it,'------------------------------------------');
   		vmParent1 = vmPopulations(worstIndex,:); % 1st member for crossover
   		vmParent2 = vmPopulations(secondWorstIndex,:); % 2nd member for crossover
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
   		[vmChildren] = crossover(vmParent1, vmParent2, chainLength, C); % Perform crossover operation
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
            fprintf(logFileID,'\n%s\n','Mutation being performed');
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
            % vmChildren
			fprintf(logFileID,'%s\n','Children ');
		    for i = 1 : C
				for j = 1 : chainLength
					fprintf(logFileID,'%d\t',vmChildren(i,j));
				end
				fprintf(logFileID,'\n');
			end
			fprintf(logFileID,'\n\n');
        end
        if mutationCount == 100 % If mutation count reaches 100
        	mutationCount = 0; % Reset it
	        mutationIterations = randperm(100,mutationProbability*100); % Then generate probability number of random iterations in which mutation will be performed
	        randomMutationIterations = TreeSet(); % Set version of the above permutation
	        for in = 1 : mutationProbability*100 % For each index
	            randomMutationIterations.add(mutationIterations(in)); % Add the index to treeset
	        end
	        fprintf(logFileID,'\n%s\n\n','Mutation iterations');
	        for i = 1 : mutationProbability*100
	            fprintf(logFileID,'%d\t',mutationIterations(i));
	        end
	        fprintf(logFileID,'\n\n');
	    end

        childrenFitnessValues = zeros(1,C);
        for cin = 1 : C % For each children
            [childrenFitnessValues(cin),t1,t2,t3,t4,t5] = calculateFitnessValue(N, VI, F, FI, L, Cvn, Xvn, Cfv, Xfv, Xsf, lambda, delta, mu, medium, network, bandwidths, nextHop, vmStatus, vnfTypes, vnfStatus, sfcClassData, vnMap, vmCapacity, vnfCapacity, preSumVnf, sIndex, vmChildren(cin,:)); % Find out the fitness value and store it
        end

        % childrenFitnessValues
		fprintf(logFileID,'%s\n','Children Fitness Values ');
	    for i = 1 : C
			fprintf(logFileID,'%d\t',childrenFitnessValues(i));
		end
		fprintf(logFileID,'\n\n');

        [childrenFitnessValues, vmChildren] = getSortedChildren(childrenFitnessValues, vmChildren, C, chainLength);
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

   		% Check for uniqueness of the child genes
   		uniqueChildren = ones(1,C);
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
	   				uniqueChildren(cin) = 0; % Mark it
	   				break;
	   			end
	   		end
        end
        fprintf(logFileID,'%s\n\n','Unique Status');
        for i = 1 : C
			fprintf(logFileID,'%d\t',uniqueChildren(i));
		end
		fprintf(logFileID,'\n\n');
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
   	end
    
   	optCost = fitnessValues(bestIndex); % Store the best fitness value
   	optPlacement = vmPopulations(bestIndex,:); % Store the corresponding placement of VMs
end