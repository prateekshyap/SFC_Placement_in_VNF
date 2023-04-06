function [Xfv, fvMap, vnfStatus, Xsf, sfcClassData, optCost] = metaHeuristicDeployment(N, VI, F, FI, S, L, Cvn, Xvn, Cfv, lambda, delta, mu, medium, network, bandwidths, nextHop, nodeStatus, vmStatus, vnfTypes, sfcClassData, vnMap, vnfFreq, vmCoreRequirements, vnfCoreRequirement, logFileID)
    
    global mutationProbability;
    global mutationCount;
    global randomMutationIterations;

    import java.util.TreeMap;
    import java.util.TreeSet;
    import java.util.ArrayList;

%     logFileID = fopen('log.txt','at');
    
    Xfv = zeros(FI,VI); %FIxVI matrix to indicate whether a vnf instance f is deployed on the VM v or not
	fvMap = TreeMap(); %Map version of Xfv
	vnfStatus = zeros(1,FI); %This will indicate which instance is of which type

    % Store the status of VNFs according to their instance counts
    statusIndex = 1;
    for f = 1 : F
        for i = 1 : vnfTypes(f)
            vnfStatus(statusIndex) = f;
            statusIndex = statusIndex+1;
        end
    end

    % Find out the prefix sum
    preSumVnf = zeros(1,F);
    for f = 2 : F
        preSumVnf(f) = vnfTypes(f-1)+preSumVnf(f-1);
    end
    
    %% Genetic algorithm
    nodeCapacity = zeros(1,N); % This will store the empty slots for the VNFs on the nodes
    vmCapacity = zeros(1,VI); % This will store the empty slots for the VNFs on the VMs
    vnfCapacity = ones(1,FI); % This will store the capacity of the VNFs in terms of how many SFCs they can serve
    for n = 1 : N % For each node
        nodeCapacity(n) = nodeStatus(n)/vnfCoreRequirement;
    end
    for v = 1 : VI % For each VM instance
        vmCapacity(v) = vmCoreRequirements(vmStatus(v))/vnfCoreRequirement;
    end
    for f = 1 : FI
        vnfCapacity(f) = ceil(vnfFreq(vnfStatus(f))/vnfTypes(vnfStatus(f))); % Get the ratio which indicates the capacity
    end
    for f = 1 : F % For each VNF type
        fvMap.put(f,ArrayList()); % Add the VNF along with an empty arraylist
    end
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

    % Setting GA parameters
    fileID = fopen('input/smallNet11/GAPar.txt','r');
    formatSpecifier = '%f';
    dimension = [1,3];

    parameters = fscanf(fileID,formatSpecifier,dimension);
    fclose(fileID);
    mutationCount = 0;
    mutationProbability = parameters(1); % probability of mutation
    if (mutationCount == 0) % If the count is 0
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

    iterations = parameters(2); % total number of GA iterations
    populationSize = parameters(3); % population size

    Xfv = zeros(FI,VI); % FIxVI matrix to indicate whether a vnf instance f is deployed on the VM v or not
    Xsf = zeros(1,FI); % SxFI matrix to indicate whether an SFC uses the f instance of VNFs or not
    
    totalIterations = S*iterations;
    onePercent = totalIterations/100;
    for fwd = 1 : 104
        fprintf(' ');
    end

    for s = 1 : S % For each SFC
        [optCost, optPlacement] = geneticAlgorithmImpl(N, VI, F, FI, L, Cvn, Xvn, Cfv, Xfv, Xsf, lambda, delta, mu, medium, network, bandwidths, nextHop, vmStatus, vmCapacity, vnfTypes, vnfStatus, vnfCapacity, sfcClassData, vnMap, fvMap, preSumVnf, iterations, populationSize, s, logFileID, onePercent, totalIterations); % Call GA
        chainLength = sfcClassData(s).chainLength;
        chain = sfcClassData(s).chain;
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
        [optCost, optPlacement, Xfv, Xsf, sfcClassData, vmCapacity, vnfCapacity] = calculateFitnessValue(N, VI, F, FI, L, Cvn, Xvn, Cfv, Xfv, Xsf, lambda, delta, mu, medium, network, bandwidths, nextHop, vmStatus, vnfTypes, vnfStatus, sfcClassData, vnMap, vmCapacity, vnfCapacity, preSumVnf, s, optPlacement); % Find out the fitness value and store it
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
        % fprintf(logFileID,'\n\n');
        % waitbar(s/S);
        fprintf(logFileID,'\n\n%d%s\n\n',s,' SFCs done****************************************************************************************************');
        fvMap = TreeMap();    
        for f = 1 : F % For each VNF type
            fvMap.put(f,ArrayList()); % Add the VNF along with an empty arraylist
        end
        for fin = 1 : FI % For each function instance
            vin = 0;
            for vin = 1 : VI % For each VM instance
                if Xfv(fin,vin) == 1 % If fin is deployed on in
                    fvMap.get(vnfStatus(fin)).add([fvMap.get(vnfStatus(fin)).size()+1 vin]);
                    break;
                end
            end
        end
    end

%     fclose(logFileID);
end