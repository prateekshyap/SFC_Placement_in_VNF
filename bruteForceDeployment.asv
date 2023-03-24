function [Xfv, fvMap, vnfStatus, Xsf, sfcClassData] = bruteForceDeployment(N, V, VI, F, FI, S, inputNetwork, network, vmTypes, vmStatus, vmCoreRequirements, vnMap, vnfTypes, vnfCoreRequirement, sfcClassData)
    global VNFDeployment;
    global SFCAssignment;
    global SFCCost;
    global SFCData;
    global globFvMap;

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

    % Backtracking solution to deploy the VNFs
    vmCapacity = zeros(1,V); % This will store the empty slots for VNFs
    nfMap = TreeMap(); % This will store whether a node contains an instance of a VNF or not
    for v = 1 : VI % For each VM instance
        vmCapacity(v) = vmCoreRequirements(vmStatus(v))/vnfCoreRequirement;
    end
    for n = 1 : N % For each node
        nfMap.put(n,TreeSet()); % Add the node along with an empty treeset
    end
    for f = 1 : F % For each VNF type
        fvMap.put(f,ArrayList()); % Add the VNF along with an empty arraylist
    end
    
    SFCCost = Inf; % Initialize the SFC assignment cost to infinity
    recurDeploy(V, VI, F, FI, S, vmStatus, vnMap, vnfTypes, vnfStatus, vmCapacity, nfMap, 1, Xfv, fvMap, sfcClassData); % Recursion call
end

function [] = recurDeploy(V, VI, F, FI, S, vmStatus, vnMap, vnfTypes, vnfStatus, vmCapacity, nfMap, fIndex, Xfv, fvMap, sfcClassData)
    global VNFDeployment;
    global SFCAssignment;
    global SFCCost;
    global SFCData;
    global globFvMap;
    if fIndex > FI %If all the instances are deployed
        [currCost, Xsf, sfcClassData] = bruteForceAssignment(F, FI, S, vnfTypes, sfcClassData, fvMap, vnMap); % Assign the SFCs in brute force manner
        if (currCost < SFCCost) % If the cost is less than the minimum cost calculated till now
            SFCCost = currCost; % Store the new minimum
            VNFDeployment = Xfv; % Store the deployment status
            SFCAssignment = Xsf; % Store the assignment status
            globFvMap = fvMap; % Store the map
            SFCData = sfcClassData; % Store the SFC class Data
        end
        return;
    end
    for v = 1 : VI % For each VM instance
        currNode = vnMap.get(v); % Get the corresponding node to vi
        if Xfv(fIndex,v) == 0 && vmCapacity(v) > 0 && nfMap.get(currNode).contains(vnfStatus(fIndex)) == 0 % If the VM is having an empty slot and f is not deployed on v and f is also not deployed on the node containing v
            Xfv(fIndex,v) = 1; % Deploy f on v
            fvMap.get(f).add([fvMap.get(f).size()+1 v]); % Store the VNF index and the VM to the map
            vmCapacity(v) = vmCapacity(v)-1; % Decrease the capacity of v by 1
            nfMap.get(currNode).add(vnfStatus(fIndex)); % Add the type of VNF to the current node
            recurDeploy(V, VI, F, FI, S, vmStatus, vnMap, vnfTypes, vnfStatus, vmCapacity, nfMap, fIndex+1, Xfv, fvMap, sfcClassData); % Recursion call
            nfMap.get(currNode).remove(vnfStatus(fIndex)); % Remove the type of VNF from the current node
            vmCapacity(v) = vmCapacity(v)+1; % Increase the capacity of v by 1
            fvMap.get(f).remove(fvMap.size()-1); % Remove the last entry from the VNF list
            Xfv(fIndex,v) = 0; % Remove f from v
        end
    end
end
   
%     vmStatus
%     vmCoreRequirements
%     vmTypes
%     vnMap
% 
%     vnfTypes
%     vnfStatus
%     vnfCoreRequirement