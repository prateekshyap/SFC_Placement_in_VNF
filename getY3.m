function [y3] = getY3(L, S, medium, network, bandwidths, nextHop, sfcClassData)
	y3 = 0;
	for s = 1 : S %1 to 5
	    currSfcLength = sfcClassData(1,s).chainLength; %Get the length of sth sfc
	    currUsedLinks = sfcClassData(1,s).usedLinks; %Get the physical nodes used
	    for e = 1 : currSfcLength-1 %For each edge in the SFC
	    	startNode = currUsedLinks(1,e); %Get the source
	    	finalNode = currUsedLinks(1,e+1); %Get the destination
	        while startNode ~= finalNode %Till we reach the destination
	        	uNode = startNode; %current node
	        	vNode = nextHop(startNode,finalNode); %next hop node
	        	y3 = y3+network(uNode,vNode)*medium; %Propagation delay
	        	y3 = y3+L/bandwidths(uNode,vNode); %Transmission delay
	        	startNode = nextHop(startNode,finalNode); %Update the start node
	        end
	    end
	end
end