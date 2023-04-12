function [currCost, Xsf, sfcClassData] = bruteForceAssignment(N, VI, F, FI, S, L, Cvn, Xvn, Cfv, Xfv, Xfvi, lambda, delta, mu, medium, network, bandwidths, nextHop, vmStatus, vnMap, vnfStatus, vnfFreq, vnfTypes, fvMap, sfcClassData)
    global minSfcCost;
    global minXsfComb;
    global minSfcData;
    global assignCount;

    minSfcCost = Inf;
    Xsf = zeros(S,FI);
    preSumVnf = zeros(1,F);
    assignCount = 0; % Initialize
    for f = 2 : F
		preSumVnf(f) = vnfTypes(f-1)+preSumVnf(f-1);
    end
    % Initialize sfcClassData objects
    for s = 1 : S
        sfcClassData(s).usedLinks = zeros(1,sfcClassData(s).chainLength);
        sfcClassData(s).usedInstances = zeros(1,sfcClassData(s).chainLength);
    end
    
    % Backtracking solution to assign the SFCs
    vnfCapacity = zeros(1,FI);
    for f = 1 : FI
        vnfCapacity(f) = ceil(sum(vnfFreq)/FI); % Get the ratio which indicates the capacity
    end
%     fprintf('Calling recur assign\n');
    recurAssign(N, VI, F, FI, S, L, Cvn, Xvn, Cfv, Xfv, Xfvi, lambda, delta, mu, medium, network, bandwidths, nextHop, vmStatus, vnMap, vnfStatus, vnfTypes, fvMap, preSumVnf, vnfCapacity, sfcClassData, 1, 1, Xsf);
    currCost = minSfcCost;
    Xsf = minXsfComb;
    sfcClassData = minSfcData;
end

function [] = recurAssign(N, VI, F, FI, S, L, Cvn, Xvn, Cfv, Xfv, Xfvi, lambda, delta, mu, medium, network, bandwidths, nextHop, vmStatus, vnMap, vnfStatus, vnfTypes, fvMap, preSumVnf, vnfCapacity, sfcClassData, sIndex, cIndex, Xsf)
    global minSfcCost;
    global minXsfComb;
    global minSfcData;
    global assignCount;

    if sIndex > S % If all VNFs in the SFC are assigned
        assignCount = assignCount+1; % Increment count
%         fprintf('Assignment combination index: %d\n',assignCount); % Print
        y1 = getY1(N, VI, FI, Cvn, Xvn, Cfv, Xfv, vmStatus, vnfStatus); % Get y1
        y2 = getY2(VI, F, FI, S, lambda, delta, mu, Xfvi, Xsf, vnfStatus); % Get y2
        y3 = getY3(L, S, medium, network, bandwidths, nextHop, sfcClassData); % Get y3
        if y1+y2+y3 < minSfcCost % If the sum is less than the minimum cost
            minSfcCost = y1+y2+y3; % Update the minimum cost
            minXsfComb = Xsf; % Update the SFC to VNF assignment
            minSfcData = sfcClassData; % Update the used links and node map
        end
        return;
    end
%     sIndex
%     cIndex
%     vnfCapacity
%     preSumVnf
    
%     sfcClassData
    chain = sfcClassData(sIndex).chain; % Get the current chain
    chainLength = sfcClassData(sIndex).chainLength; % Get the current chain length
%     for c = 1 : chainLength % For each VNF present in SFC
    currVnf = chain(cIndex); % Get the current VNF
    currVnfCount = vnfTypes(currVnf); % Get the instance count for the current VNF
    for i = 1 : currVnfCount % For each VNF instance for current VNF
        if (vnfCapacity(preSumVnf(currVnf)+i) > 0) % If the corresponding VNF can serve more SFCs
            Xsf(sIndex,preSumVnf(currVnf)+i) = 1; % Assign the instance
            vnfCapacity(preSumVnf(currVnf)+i) = vnfCapacity(preSumVnf(currVnf)+i)-1; % Decrease capacity by 1
            chosenVM = fvMap.get(currVnf).get(i-1); % Get the corresponding VM
            chosenNode = vnMap.get(chosenVM(2)); % Get the corresponding Node
            sfcClassData(sIndex).usedLinks(cIndex) = chosenNode; % Store the physical node to the array
            sfcClassData(sIndex).usedInstances(cIndex) = preSumVnf(currVnf)+chosenVM(1); % Store the corresponding function instance
%             cIndex
%             chainLength
            if (cIndex == chainLength) % If the current chain is over, reset cIndex to 1 and increment sIndex by 1
%                 fprintf('Calling if recur assign\n');
                recurAssign(N, VI, F, FI, S, L, Cvn, Xvn, Cfv, Xfv, Xfvi, lambda, delta, mu, medium, network, bandwidths, nextHop, vmStatus, vnMap, vnfStatus, vnfTypes, fvMap, preSumVnf, vnfCapacity, sfcClassData, sIndex+1, 1, Xsf);
            else % Otherwise keep sIndex constant and increment cIndex by 1
%                 fprintf('Calling else recur assign\n');
                recurAssign(N, VI, F, FI, S, L, Cvn, Xvn, Cfv, Xfv, Xfvi, lambda, delta, mu, medium, network, bandwidths, nextHop, vmStatus, vnMap, vnfStatus, vnfTypes, fvMap, preSumVnf, vnfCapacity, sfcClassData, sIndex, cIndex+1, Xsf);
            end
            sfcClassData(sIndex).usedInstances(cIndex) = 0; % Reset function instance
            sfcClassData(sIndex).usedLinks(cIndex) = 0; % Reset physical node
            vnfCapacity(preSumVnf(currVnf)+i) = 0; % Reset VNF capacity
            Xsf(sIndex,preSumVnf(currVnf)+i) = 0; % Remove s from f
        end
    end
%     end
end