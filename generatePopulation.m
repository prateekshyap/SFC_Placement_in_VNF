function[nodePop, vmPop] = generatePopulation(N, VI, chainLength, r, nodeClassData)
    
    import java.util.TreeSet;

	% These two matrices will store the population for each level of reliability
	nodePop = zeros(chainLength,r);
	vmPop = zeros(chainLength,r);

    %% No Failure
	nodePop(:,1) = randperm(N,chainLength); % Generate a random chromosome for the first level
    % Populate VMs accordingly
    for c = 1 : chainLength % For the entire length of the chain
        currNodeVmCount = nodeClassData(nodePop(c,1)).vmCount; % Get the VM count of the corresponding node from the node population
        currNodeVms = nodeClassData(nodePop(c,1)).vms; % Get the list of VMs
        vmIndex = randi(currNodeVmCount); % Generate a random Index
        vmPop(c,1) = currNodeVms(vmIndex); % Store the corresponding VM in the vm population
    end

    %% Failure
    for iota = 2 : r % For the next levels of reliability
        % The logic is to ensure that we generate enough random nodes such
        % that picking one node out of them will guarantee that it is
        % different from the nodes picked in the previous reliability
        % levels
        % For example:
        % If for the 4th position in a 7-length chain, in level-1 we have
        % 8th node and in level-2 we have 3rd node, then for the current
        % iota value i.e. 3 we shall generate 3 random nodes.
        % In the worst case those 3 values could be 8, 3, x.
        % This means even if all the previously used nodes are repeated, we
        % shall still have one node (x in this case) which is new and
        % unique and we can use it for the current reliability level
        newNodePop = zeros(iota,chainLength); % This will store the newly generated population
        for c = 1 : chainLength % For each column i.e chain position
            newNodePop(:,c) = randperm(N,iota); % Generate a random chromosome
        end
        for c = 1 : chainLength % For each position
            failedNodes = TreeSet(); % This will store the nodes that are already used in previous levels
            for l = 1 : iota-1 % For each previous level
                failedNodes.add(nodePop(c,l)); % Add the node that is used
            end
            for l = 1 : iota % For each node in the new population
                if ~failedNodes.contains(newNodePop(l,c)) % If the set does not contain it
                    nodePop(c,iota) = newNodePop(l,c); % Store it in the population
                    break;
                end
            end
        end
        % Populate VMs accordingly
        for c = 1 : chainLength % For the entire length of the chain
            currNodeVmCount = nodeClassData(nodePop(c,iota)).vmCount; % Get the VM count of the corresponding node from the node population
            currNodeVms = nodeClassData(nodePop(c,iota)).vms; % Get the list of VMs
            vmIndex = randi(currNodeVmCount); % Generate a random Index
            vmPop(c,iota) = currNodeVms(vmIndex); % Store the corresponding VM in the vm population
        end
    end
end