function [Xfv, fvMap, vnfStatus, Xsf, sfcClassData, optCost] = metaHeuristicDeployment(N, VI, F, FI, S, L, Cvn, Xvn, Cfv, lambda, delta, mu, medium, network, bandwidths, nextHop, nodeStatus, vmStatus, vnfTypes, sfcClassData, vnMap, vnfFreq, vmCoreRequirements, vnfCoreRequirement)
    
    global mutationProbability;
    global mutationCount;
    global randomMutationIterations;

    import java.util.TreeMap;
    import java.util.TreeSet;
    import java.util.ArrayList;
    
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
    vnfCapacity = zeros(1,FI); % This will store the capacity of the VNFs in terms of how many SFCs they can serve
    for n = 1 : N % For each node
        nodeCapacity(n) = nodeStatus(n)/vnfCoreRequirement;
    end
    for v = 1 : VI % For each VM instance
        vmCapacity(v) = vmCoreRequirements(vmStatus(v))/vnfCoreRequirement;
    end
    for f = 1 : F % For each VNF type
        fvMap.put(f,ArrayList()); % Add the VNF along with an empty arraylist
    end

    % Setting GA parameters
    fileID = fopen('input/smallNet8/GAPar.txt','r');
    formatSpecifier = '%f';
    dimension = [1,3];

    parameters = fscanf(fileID,formatSpecifier,dimension);
    mutationCount = 0;
    mutationProbability = parameters(1); % probability of mutation
    if (mutationCount == 0) % If the count is 0
        mutationIterations = randperm(100,mutationProbability*100); % Then generate probability number of random iterations in which mutation will be performed
        randomMutationIterations = TreeSet(); % Set version of the above permutation
        for in = 1 : mutationProbability*100 % For each index
            randomMutationIterations.add(mutationIterations(in)); % Add the index to treeset
        end
    end

    iterations = parameters(2); % total number of GA iterations
    populationSize = parameters(3); % population size

    Xfv = zeros(FI,VI); % FIxVI matrix to indicate whether a vnf instance f is deployed on the VM v or not
    Xsf = zeros(1,FI); % SxFI matrix to indicate whether an SFC uses the f instance of VNFs or not

    for s = 1 : S % For each SFC
        [optCost, optPlacement] = geneticAlgorithmImpl(N, VI, F, FI, S, L, Cvn, Xvn, Cfv, Xfv, Xsf, lambda, delta, mu, medium, network, bandwidths, nextHop, nodeStatus, vmStatus, vnfTypes, vnfStatus, sfcClassData, vnMap, vnfFreq, vmCoreRequirements, vnfCoreRequirement, nodeCapacity, vmCapacity, vnfCapacity, preSumVnf, iterations, populationSize, s); % Call GA
    end
end