%% Before starting the process, print the details of the entire input that is being considered
fprintf(logFileID,'%s\n','=========================================================================================');
fprintf(logFileID,'%s%d\n','                                   Observation ',loop);
fprintf(logFileID,'%s\n','=========================================================================================');
fprintf(logFileID,'\n');
fprintf(logFileID,'%s\n\n','----------------------------------Physical Network---------------------------------------');
for i = 1 : N
	for j = 1 : N
		fprintf(logFileID,'%d\t',inputNetwork(i,j));
	end
	fprintf(logFileID,'\n');
end
fprintf(logFileID,'\n');
fprintf(logFileID,'%s\n\n','----------------------------------Network Bandwidth--------------------------------------');
for i = 1 : N
	for j = 1 : N
		fprintf(logFileID,'%d\t',bandwidths(i,j));
	end
	fprintf(logFileID,'\n');
end
fprintf(logFileID,'\n');
fprintf(logFileID,'%s\n\n','--------------------------------------Node Types-----------------------------------------');
for i = 1 : N
	fprintf(logFileID,'%d\t',nodeStatus(i));
end
fprintf(logFileID,'\n\n');
fprintf(logFileID,'%s\n\n','---------------------------------------VM Cores------------------------------------------');
for i = 1 : V
	fprintf(logFileID,'%d\t',vmCoreRequirements(i));
end
fprintf(logFileID,'\n\n');
fprintf(logFileID,'%s\n\n','---------------------------------------VNF Types-----------------------------------------');
fprintf(logFileID,'%s%d\n','F: ',F);
fprintf(logFileID,'%s%d\n','VNF Cores: ',vnfCoreRequirement);
fprintf(logFileID,'\n\n');
fprintf(logFileID,'%s\n\n','----------------------------------Transmission medium------------------------------------');
fprintf(logFileID,'%d\n\n',medium);
fprintf(logFileID,'%s\n\n','--------------------------------------Packet size----------------------------------------');
fprintf(logFileID,'%d\n\n',L);
fprintf(logFileID,'%s\n\n','----------------------Data Generated from Floyd-Warshall Algorithm-----------------------');
fprintf(logFileID,'%s\n\n','Shortest Paths');
for i = 1 : N
	for j = 1 : N
		fprintf(logFileID,'%d\t',network(i,j));
	end
	fprintf(logFileID,'\n');
end
fprintf(logFileID,'\n\n%s\n\n','Next Hops');
for i = 1 : N
	for j = 1 : N
		fprintf(logFileID,'%d\t',nextHop(i,j));
	end
	fprintf(logFileID,'\n');
end
fprintf(logFileID,'\n');
fprintf(logFileID,'%s\n\n','-------------------------------------------Cvn-------------------------------------------');
for i = 1 : V
	fprintf(logFileID,'%d\t',Cvn(i));
end
fprintf(logFileID,'\n\n');
fprintf(logFileID,'%s\n\n','-------------------------------------------Cfv-------------------------------------------');
for i = 1 : F
	fprintf(logFileID,'%d\t',Cfv(i));
end
fprintf(logFileID,'\n\n');
fprintf(logFileID,'%s\n\n','--------------------------------------Arrival Rate---------------------------------------');
for i = 1 : S
	for j = 1 : F
		fprintf(logFileID,'%d\t',lambda(i,j));
	end
	fprintf(logFileID,'\n');
end
fprintf(logFileID,'\n\n');
fprintf(logFileID,'%s\n\n','----------------------------------------Drop Rate----------------------------------------');
for i = 1 : S
	for j = 1 : F
		fprintf(logFileID,'%d\t',delta(i,j));
	end
	fprintf(logFileID,'\n');
end
fprintf(logFileID,'\n\n');
fprintf(logFileID,'%s\n\n','--------------------------------------Service Rate---------------------------------------');
for i = 1 : F
	fprintf(logFileID,'%d\t',mu(i));
end
fprintf(logFileID,'\n\n');


%% After VM Hosting, print the generated data
fprintf(logFileID,'\n');
fprintf(logFileID,'%s\n\n','-------------------------------------------VI--------------------------------------------');
fprintf(logFileID,'%d\n',VI);
fprintf(logFileID,'\n');
fprintf(logFileID,'%s\n\n','------------------------------------------Xvn--------------------------------------------');
for i = 1 : VI
	for j = 1 : N
		fprintf(logFileID,'%d\t',Xvn(i,j));
	end
	fprintf(logFileID,'\n');
end
fprintf(logFileID,'\n\n');
fprintf(logFileID,'%s\n\n','-----------------------------------------VN Map------------------------------------------');
for i = 1 : VI
	fprintf(logFileID,'%d -> %d\n',i,vnMap.get(i));
end
fprintf(logFileID,'\n');
fprintf(logFileID,'%s\n\n','----------------------------------------VM Counts----------------------------------------');
for i = 1 : V
	fprintf(logFileID,'%d\t',vmTypes(i));
end
fprintf(logFileID,'\n\n');
fprintf(logFileID,'%s\n\n','------------------------------------------SFCs-------------------------------------------');
for s = 1 : S
    fprintf(logFileID,'%s%d\n','length: ',sfcClassData(s).chainLength);
    fprintf(logFileID,'%s\n','chain ');
    for i = 1 : sfcClassData(s).chainLength
		fprintf(logFileID,'%d\t',sfcClassData(s).chain(i));
	end
	fprintf(logFileID,'\n\n');
end


%% After VNF Instance Counting, print the generated data
fprintf(logFileID,'\n');
fprintf(logFileID,'%s\n\n','-------------------------------------------FI--------------------------------------------');
fprintf(logFileID,'%d\n',FI);
fprintf(logFileID,'\n');
fprintf(logFileID,'%s\n\n','----------------------------------------VNF Freqs----------------------------------------');
for i = 1 : F
	fprintf(logFileID,'%d\t',vnfFreq(i));
end
fprintf(logFileID,'\n\n');
fprintf(logFileID,'%s\n\n','----------------------------------------VNF Counts---------------------------------------');
for i = 1 : F
	fprintf(logFileID,'%d\t',vnfTypes(i));
end
fprintf(logFileID,'\n\n');


%% After Deployment and Assignment, print the generated data
fprintf(logFileID,'\n\n');
fprintf(logFileID,'%s\n\n','-------------------------------------------Xfv-------------------------------------------');
for i = 1 : FI
    for j = 1 : VI
        fprintf(logFileID,'%d\t',Xfv(i,j));
    end
    fprintf(logFileID,'\n');
end
fprintf(logFileID,'\n\n');
fprintf(logFileID,'%s\n\n','-----------------------------------------FV Map------------------------------------------');
for i = 1 : F
	fprintf(logFileID,'%s%d\n','f',i);
	instanceVMList = fvMap.get(i);
	vnfCount = instanceVMList.size();
	for j = 1 : vnfCount
        instanceDetails = instanceVMList.get(j-1);
		fprintf(logFileID,'\t%s%d%s%d\n','Instance: ',instanceDetails(1),' -> ',instanceDetails(2));
	end
end
fprintf(logFileID,'\n\n');
fprintf(logFileID,'%s\n\n','-------------------------------------------Xsf-------------------------------------------');
for i = 1 : S
    for j = 1 : FI
        fprintf(logFileID,'%d\t',Xsf(i,j));
    end
    fprintf(logFileID,'\n');
end
fprintf(logFileID,'\n\n');
fprintf(logFileID,'%s\n\n','---------------------------------------SFC Details---------------------------------------');
for s = 1 : S
    fprintf(logFileID,'%s%d\n','length: ',sfcClassData(s).chainLength);
    fprintf(logFileID,'%s\n','chain ');
    for i = 1 : sfcClassData(s).chainLength
        fprintf(logFileID,'%d\t',sfcClassData(s).chain(i));
    end
    fprintf(logFileID,'\n\n');
    fprintf(logFileID,'%s\n','Used Links ');
    for i = 1 : sfcClassData(s).chainLength
        fprintf(logFileID,'%d\t',sfcClassData(s).usedLinks(i));
    end
    fprintf(logFileID,'\n\n');
    fprintf(logFileID,'%s\n','Used Function Instances ');
    for i = 1 : sfcClassData(s).chainLength
        fprintf(logFileID,'%d\t',sfcClassData(s).usedInstances(i));
    end
    fprintf(logFileID,'\n\n');
end


%% Removed from metaHeuristicDeployment.m
fprintf(logFileID,'%s\n\n','------------------------------------------VM Capacity---------------------------------------');
for i = 1 : VI
    fprintf(logFileID,'%d\t',vmCapacity(i));
end
fprintf(logFileID,'\n\n');
fprintf(logFileID,'%s\n\n','------------------------------------------VNF Capacity--------------------------------------');
for i = 1 : FI
    fprintf(logFileID,'%d\t',vnfCapacity(i));
end
fprintf(logFileID,'\n\n');
fprintf(logFileID,'\n%s\n\n','Mutation iterations');
for i = 1 : mutationProbability*100
    fprintf(logFileID,'%d\t',mutationIterations(i));
end
fprintf(logFileID,'\n\n');
fprintf(logFileID,'\n\n');
fprintf(logFileID,'%d',optCost);
fprintf(logFileID,'\n\n');
for i = 1 : chainLength
    fprintf(logFileID,'%d\t',optPlacement(i));
end
fprintf(logFileID,'\n\n');
fprintf(logFileID,'%s\n\n','VM Capacity');
for i = 1 : VI
    fprintf(logFileID,'%d\t',vmCapacity(i));
end
fprintf(logFileID,'\n\n');
fprintf(logFileID,'%s\n\n','VNF Capacity');
for i = 1 : FI
    fprintf(logFileID,'%d\t',vnfCapacity(i));
end
fprintf(logFileID,'%s\n\n','VM Capacity');
for i = 1 : VI
    fprintf(logFileID,'%d\t',vmCapacity(i));
end
fprintf(logFileID,'\n\n');
fprintf(logFileID,'%s\n\n','VNF Capacity');
for i = 1 : FI
    fprintf(logFileID,'%d\t',vnfCapacity(i));
end
fprintf(logFileID,'\n\n');
fprintf(logFileID,'%s\n\n','-------------------------------------------Xfv-------------------------------------------');
for i = 1 : FI
    for j = 1 : VI
        fprintf(logFileID,'%d\t',Xfv(i,j));
    end
    fprintf(logFileID,'\n');
end
fprintf(logFileID,'\n\n');
fprintf(logFileID,'%s\n\n','-----------------------------------------FV Map------------------------------------------');
for i = 1 : F
    fprintf(logFileID,'%s%d\n','f',i);
    instanceVMList = fvMap.get(i);
    vnfCount = instanceVMList.size();
    for j = 1 : vnfCount
        instanceDetails = instanceVMList.get(j-1);
        fprintf(logFileID,'\t%s%d%s%d\n','Instance: ',instanceDetails(1),' -> ',instanceDetails(2));
    end
end
fprintf(logFileID,'\n\n');
fprintf(logFileID,'%s\n\n','-------------------------------------------Xsf-------------------------------------------');
for i = 1 : s
    for j = 1 : FI
        fprintf(logFileID,'%d\t',Xsf(i,j));
    end
    fprintf(logFileID,'\n');
end
fprintf(logFileID,'\n\n%d%s\n\n',s,' SFCs done****************************************************************************************************');


%% Removed from geneticAlgorithm.m
sfcClassData(sIndex).chain
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
fprintf(logFileID,'%s%d%s\n\n','-------------------------------------------Iteration number: ',it,'------------------------------------------');
fprintf(logFileID,'%s\n','Children ');
   for i = 1 : C
	for j = 1 : chainLength
		fprintf(logFileID,'%d\t',vmChildren(i,j));
	end
	fprintf(logFileID,'\n');
end
fprintf(logFileID,'\n\n');
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
      fprintf(logFileID,'%s\n\n','Unique Status');
      for i = 1 : C
	fprintf(logFileID,'%d\t',uniqueChildren(i));
end
fprintf(logFileID,'\n\n');














	% Mutation
	%{
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
%}