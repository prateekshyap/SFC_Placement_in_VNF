function [currCost, Xsf, sfcClassData] = bruteForceAssignment(F, FI, S, vnfTypes, sfcClassData, fvMap, vnMap)
    global minSfcCost;

    Xsf = zeros(S,FI);
    preSumVnf = zeros(1,F);
    for i = 2 : F
		preSumVnf(1,i) = vnfTypes(1,i-1)+preSumVnf(1,i-1);
	end
    
end