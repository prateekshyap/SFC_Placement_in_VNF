function [Xfv, fvMap, vnfStatus] = metaHeuristicDeployment(VI, F, FI, vnfTypes)
    
    import java.util.TreeMap;
    
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
    
    
end