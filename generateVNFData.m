function [FI, vnfTypes] = generateVNFData(V, F, S, vmTypes, vmCoreRequirements, sfcClassData)
    
    FI = 0; %Total number of function instances
    vnfTypes = zeros(1,F); % This stores the count of each VNF type

    % Find out the total number of VNF instances possible
    for v = 1 : V %For each VM
        FI = FI+(vmTypes(v)*vmCoreRequirements(v)/16); %
    end

    % Find out the total requirement of each VNF type
    vnfFreq = zeros(1,F);
    for s = 1 : S % For each SFC
        chain = sfcClassData(s).chain;
        chainLength = sfcClassData(s).chainLength;
        for c = 1 : chainLength % For each VNF in the chain
            vnfFreq(chain(c)) = vnfFreq(chain(c))+1; % Increment the frequency of the corresponding VNF
        end
    end

    % Find out the minimum number of instances required for each VNF type
    ratio = FI/sum(vnfFreq); % This ratio indicates the ratio of possible instances to required instances
    for f = 1 : F % For each VNF type
        vnfTypes(f) = floor(vnfFreq(f)*ratio); % Multiply the ratio and take the floor value
    end
    
    % Now that we have found out the minimum number of instances possible
    % for each VNF
    % Find out if there is any difference between FI and the current total
    % instances
    % If there is any difference then we need to add some more instances to
    % match FI
    remInstances = FI - sum(vnfTypes); % Find out the remaining instances
    extraVNFs = randperm(F); % Generate a random permutation of VNFs to increment their instances
    % Increment the instance count for the first remInstances VNFs
    for i = 1 : remInstances % For each remaining instance
        vnfTypes(extraVNFs(i)) = vnfTypes(extraVNFs(i))+1; % Increment the instance count for the corresponding VNF
    end
    
    % This part of the code will increase the instance count for such VNFs
    % whose current instance count is 1
    % Because we are solving the problem of reliability, so we need at
    % least two instances of each function
    for f = 1 : F % For each VNF type
        while vnfTypes(f) < 2 % Till less than two instances available
            maxFreq = max(vnfTypes); % Get the maximum frequency
            for g = 1 : F % For each VNF type
                if vnfTypes(g) == maxFreq % If the maximum frequency is found
                    vnfTypes(g) = vnfTypes(g)-1; % Decrease the maximum frequency by 1
                    vnfTypes(f) = vnfTypes(f)+1; % Increase the frequency of the chosen function by 1
                    break;
                end
            end
        end
    end

    % Now vnfTypes is guaranteed to have a good combination of instance
    % counts which considers the frequency of the VNFs as well as the
    % reliability factor and also looks random
end